#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

#--------------------------------------------------------------
# OIDC Provider Lookup (validates the provider exists in IAM)
#--------------------------------------------------------------

data "aws_iam_openid_connect_provider" "eks" {
  count = local.needs_irsa && var.eks_oidc_provider_arn == "" ? 1 : 0
  url   = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

#--------------------------------------------------------------
# Profile Routing Booleans
#--------------------------------------------------------------

locals {
  # Profile selection booleans
  is_managed_metrics  = var.collector_profile == "managed-metrics"
  is_self_managed_amp = var.collector_profile == "self-managed-amp"
  is_cloudwatch_otlp  = var.collector_profile == "cloudwatch-otlp"

  # Derived booleans
  needs_otel_helm = local.is_self_managed_amp || local.is_cloudwatch_otlp
  needs_irsa      = local.needs_otel_helm
  is_amp_flavor   = local.is_managed_metrics || local.is_self_managed_amp
  is_cw_flavor    = local.is_cloudwatch_otlp
}

#--------------------------------------------------------------
# Common Computed Values
#--------------------------------------------------------------

locals {
  region               = data.aws_region.current.id
  partition            = data.aws_partition.current.partition
  account_id           = data.aws_caller_identity.current.account_id

  # Derive OIDC provider ARN from EKS cluster when not explicitly provided
  eks_oidc_issuer_url   = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = var.eks_oidc_provider_arn != "" ? var.eks_oidc_provider_arn : (
    local.needs_irsa ? data.aws_iam_openid_connect_provider.eks[0].arn : "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
  )
}

#--------------------------------------------------------------
# AMP Workspace Computation
#--------------------------------------------------------------

locals {
  amp_workspace_id = var.create_amp_workspace ? aws_prometheus_workspace.this[0].id : var.managed_prometheus_workspace_id

  amp_workspace_arn = var.create_amp_workspace ? aws_prometheus_workspace.this[0].arn : (
    var.managed_prometheus_workspace_id != null ? data.aws_prometheus_workspace.existing[0].arn : null
  )

  amp_workspace_endpoint = local.is_amp_flavor ? "https://aps-workspaces.${local.region}.amazonaws.com/workspaces/${local.amp_workspace_id}/" : null

  # CloudWatch OTLP metrics endpoint — default to regional endpoint when not provided
  cw_metrics_endpoint = var.cloudwatch_metrics_endpoint != "" ? var.cloudwatch_metrics_endpoint : "https://monitoring.${local.region}.amazonaws.com/v1/metrics"
}

# Precondition: fail when create_amp_workspace = false and no workspace ID provided
resource "terraform_data" "amp_workspace_validation" {
  count = local.is_amp_flavor && !var.create_amp_workspace ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.managed_prometheus_workspace_id != null
      error_message = "managed_prometheus_workspace_id must be provided when create_amp_workspace is false and an AMP flavor profile is selected"
    }
  }
}

#--------------------------------------------------------------
# Dashboard Sources
#--------------------------------------------------------------

locals {
  default_dashboard_sources = {
    cluster             = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/cluster.json"
    kubelet             = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/kubelet.json"
    namespace-workloads = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/namespace-workloads.json"
    node-exporter       = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/nodeexporter-nodes.json"
    nodes               = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/nodes.json"
    workloads           = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/workloads.json"
  }

  dashboard_sources = length(var.dashboard_sources) > 0 ? var.dashboard_sources : local.default_dashboard_sources

  # Dashboards are provisioned only when delivery method is terraform AND enable_dashboards is true
  provision_dashboards = var.dashboard_delivery_method == "terraform" && var.enable_dashboards
}

#--------------------------------------------------------------
# Default Scrape Configs (shared by OTel profiles)
#--------------------------------------------------------------

locals {
  default_otel_scrape_configs = [
    {
      job_name        = "kube-state-metrics"
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      static_configs = [
        { targets = ["kube-state-metrics.kube-system.svc.cluster.local:8080"] }
      ]
    },
    {
      job_name        = "node-exporter"
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      static_configs = [
        { targets = ["prometheus-node-exporter.prometheus-node-exporter.svc.cluster.local:9100"] }
      ]
    },
    {
      job_name = "kubelet"
      scheme   = "https"
      tls_config = {
        ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        insecure_skip_verify = true
      }
      bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      kubernetes_sd_configs = [
        { role = "node" }
      ]
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      relabel_configs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        }
      ]
    },
    {
      job_name     = "kubelet-cadvisor"
      scheme       = "https"
      metrics_path = "/metrics/cadvisor"
      tls_config = {
        ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        insecure_skip_verify = true
      }
      bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      kubernetes_sd_configs = [
        { role = "node" }
      ]
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      relabel_configs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        }
      ]
    },
  ]
}

#--------------------------------------------------------------
# CloudWatch OTLP — OTel Collector Values
#--------------------------------------------------------------

locals {
  cloudwatch_otel_collector_values = local.is_cloudwatch_otlp ? yamlencode({
    mode = "deployment"

    serviceAccount = {
      create = true
      name   = "otel-collector"
      annotations = {
        "eks.amazonaws.com/role-arn" = try(module.collector_irsa_role[0].iam_role_arn, "")
      }
    }

    clusterRole = {
      create = true
      rules = [
        {
          apiGroups = [""]
          resources = ["nodes", "nodes/proxy", "nodes/metrics", "services", "endpoints", "pods"]
          verbs     = ["get", "list", "watch"]
        },
        {
          nonResourceURLs = ["/metrics", "/metrics/cadvisor"]
          verbs           = ["get"]
        },
      ]
    }

    # Override chart defaults by explicitly setting only our config.
    # Null out default receivers/exporters/processors the chart injects.
    config = {
      extensions = {
        health_check = {}
        "sigv4auth/monitoring" = {
          service = "monitoring"
          region  = local.region
        }
        "sigv4auth/xray" = {
          service = "xray"
          region  = local.region
        }
        "sigv4auth/logs" = {
          service = "logs"
          region  = local.region
        }
      }

      receivers = {
        prometheus = {
          config = {
            scrape_configs = local.default_otel_scrape_configs
          }
        }
        otlp = {
          protocols = {
            grpc = { endpoint = "0.0.0.0:4317" }
            http = { endpoint = "0.0.0.0:4318" }
          }
        }
        jaeger  = null
        zipkin  = null
      }

      processors = {
        # Delete blank resource attributes that Zeus rejects with:
        # "Attribute string value cannot be blank [ResourceMetrics.N]"
        # The Prometheus receiver can produce empty string attributes from
        # kubernetes_sd_configs metadata labels that have no value.
        "transform/drop_blank_attrs" = {
          error_mode = "ignore"
          resource_statements = [
            {
              context    = "resource"
              statements = [
                "delete_key(attributes, \"net.host.name\") where attributes[\"net.host.name\"] == \"\"",
                "delete_key(attributes, \"net.host.port\") where attributes[\"net.host.port\"] == \"\"",
                "delete_key(attributes, \"http.scheme\") where attributes[\"http.scheme\"] == \"\"",
                "delete_key(attributes, \"service.instance.id\") where attributes[\"service.instance.id\"] == \"\"",
                "delete_key(attributes, \"service.name\") where attributes[\"service.name\"] == \"\"",
              ]
            }
          ]
        }
        batch = {
          send_batch_max_size = 200
          send_batch_size     = 200
          timeout             = "5s"
        }
        memory_limiter = null
      }

      exporters = {
        logging = null
        debug   = null
        "otlphttp/metrics" = {
          endpoint = local.cw_metrics_endpoint
          auth = {
            authenticator = "sigv4auth/monitoring"
          }
        }
        "otlphttp/traces" = {
          endpoint = "https://xray.${local.region}.amazonaws.com/v1/traces"
          auth = {
            authenticator = "sigv4auth/xray"
          }
        }
        "otlphttp/logs" = {
          endpoint = "https://logs.${local.region}.amazonaws.com/v1/logs"
          auth = {
            authenticator = "sigv4auth/logs"
          }
          headers = {
            "x-aws-log-group"  = var.cloudwatch_log_group
            "x-aws-log-stream" = var.cloudwatch_log_stream
          }
        }
      }

      service = {
        extensions = ["health_check", "sigv4auth/monitoring", "sigv4auth/xray", "sigv4auth/logs"]
        pipelines = {
          metrics = {
            receivers  = ["prometheus", "otlp"]
            processors = ["transform/drop_blank_attrs", "batch"]
            exporters  = ["otlphttp/metrics"]
          }
          traces = {
            receivers  = ["otlp"]
            processors = ["batch"]
            exporters  = ["otlphttp/traces"]
          }
          logs = {
            receivers  = ["otlp"]
            processors = ["batch"]
            exporters  = ["otlphttp/logs"]
          }
        }
      }
    }
  }) : ""

  #--------------------------------------------------------------
  # Self-Managed AMP — OTel Collector Values
  #--------------------------------------------------------------

  self_managed_amp_otel_collector_values = local.is_self_managed_amp ? yamlencode({
    mode = "deployment"

    serviceAccount = {
      create = true
      name   = "otel-collector"
      annotations = {
        "eks.amazonaws.com/role-arn" = try(module.collector_irsa_role[0].iam_role_arn, "")
      }
    }

    clusterRole = {
      create = true
      rules = [
        {
          apiGroups = [""]
          resources = ["nodes", "nodes/proxy", "nodes/metrics", "services", "endpoints", "pods"]
          verbs     = ["get", "list", "watch"]
        },
        {
          nonResourceURLs = ["/metrics", "/metrics/cadvisor"]
          verbs           = ["get"]
        },
      ]
    }

    # Override chart defaults by explicitly setting only our config.
    # Null out default receivers/exporters/processors the chart injects.
    config = {
      extensions = {
        health_check = {}
        "sigv4auth/aps" = {
          service = "aps"
          region  = local.region
        }
        "sigv4auth/xray" = {
          service = "xray"
          region  = local.region
        }
        "sigv4auth/logs" = {
          service = "logs"
          region  = local.region
        }
      }

      receivers = {
        prometheus = {
          config = {
            scrape_configs = local.default_otel_scrape_configs
          }
        }
        otlp = {
          protocols = {
            grpc = { endpoint = "0.0.0.0:4317" }
            http = { endpoint = "0.0.0.0:4318" }
          }
        }
        jaeger  = null
        zipkin  = null
      }

      processors = {
        batch = {
          send_batch_max_size = 200
          send_batch_size     = 200
          timeout             = "5s"
        }
        memory_limiter = null
      }

      exporters = merge(
        {
          logging = null
          debug   = null
          prometheusremotewrite = {
            endpoint = "${local.amp_workspace_endpoint}api/v1/remote_write"
            auth = {
              authenticator = "sigv4auth/aps"
            }
          }
        },
        var.enable_tracing ? {
          "otlphttp/xray" = {
            endpoint = "https://xray.${local.region}.amazonaws.com/v1/traces"
            auth = {
              authenticator = "sigv4auth/xray"
            }
          }
        } : {},
        var.enable_logs ? {
          "otlphttp/cwlogs" = {
            endpoint = "https://logs.${local.region}.amazonaws.com/v1/logs"
            auth = {
              authenticator = "sigv4auth/logs"
            }
          }
        } : {},
      )

      service = {
        extensions = compact([
          "health_check",
          "sigv4auth/aps",
          var.enable_tracing ? "sigv4auth/xray" : "",
          var.enable_logs ? "sigv4auth/logs" : "",
        ])
        pipelines = merge(
          {
            metrics = {
              receivers  = ["prometheus", "otlp"]
              processors = ["batch"]
              exporters  = ["prometheusremotewrite"]
            }
          },
          var.enable_tracing ? {
            traces = {
              receivers  = ["otlp"]
              processors = ["batch"]
              exporters  = ["otlphttp/xray"]
            }
          } : {},
          var.enable_logs ? {
            logs = {
              receivers  = ["otlp"]
              processors = ["batch"]
              exporters  = ["otlphttp/cwlogs"]
            }
          } : {},
        )
      }
    }
  }) : ""

  # Profile-driven OTel Collector values
  otel_collector_values = (
    local.is_cloudwatch_otlp ? local.cloudwatch_otel_collector_values :
    local.is_self_managed_amp ? local.self_managed_amp_otel_collector_values :
    ""
  )
}

#--------------------------------------------------------------
# Scrape Configuration Renderer (managed-metrics profile)
#--------------------------------------------------------------

locals {
  default_scrape_jobs = [
    {
      job_name        = "kube-state-metrics"
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      static_configs = [
        { targets = ["kube-state-metrics.kube-system.svc.cluster.local:8080"] }
      ]
    },
    {
      job_name        = "node-exporter"
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      static_configs = [
        { targets = ["prometheus-node-exporter.prometheus-node-exporter.svc.cluster.local:9100"] }
      ]
    },
    {
      job_name = "kubelet"
      scheme   = "https"
      tls_config = {
        ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        insecure_skip_verify = true
      }
      bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      kubernetes_sd_configs = [
        { role = "node" }
      ]
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      relabel_configs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        }
      ]
    },
    {
      job_name     = "kubelet-cadvisor"
      scheme       = "https"
      metrics_path = "/metrics/cadvisor"
      tls_config = {
        ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        insecure_skip_verify = true
      }
      bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
      kubernetes_sd_configs = [
        { role = "node" }
      ]
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
      relabel_configs = [
        {
          action = "labelmap"
          regex  = "__meta_kubernetes_node_label_(.+)"
        }
      ]
    },
  ]

  all_scrape_jobs = concat(local.default_scrape_jobs, var.additional_scrape_jobs)

  scrape_configuration_yaml = var.scrape_configuration != "" ? var.scrape_configuration : yamlencode({
    global = {
      scrape_interval = var.prometheus_config.global_scrape_interval
      scrape_timeout  = var.prometheus_config.global_scrape_timeout
    }
    scrape_configs = local.all_scrape_jobs
  })

  scrape_configuration_base64 = base64encode(local.scrape_configuration_yaml)
}
