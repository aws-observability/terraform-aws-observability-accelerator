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
  is_container_insights = false # future: var.collector_profile == "cloudwatch-container-insights"

  # Derived booleans
  # OTel Helm chart only needed for self-managed-amp.
  # cloudwatch-otlp uses the CW Agent EKS add-on (no OTel Helm).
  needs_otel_helm = local.is_self_managed_amp
  needs_irsa      = local.needs_otel_helm
  is_amp_flavor   = local.is_managed_metrics || local.is_self_managed_amp
  is_cw_flavor    = local.is_cloudwatch_otlp

  # OTLP gateway: CWA Deployment with OTLP receivers for app telemetry
  needs_otlp_gateway = local.is_cloudwatch_otlp && var.enable_otlp_gateway

  # Helm support charts (kube-state-metrics, node-exporter) only for AMP
  # profiles. The CW Agent add-on bundles its own KSM + node-exporter.
  needs_helm_support = local.is_amp_flavor
}

#--------------------------------------------------------------
# Common Computed Values
#--------------------------------------------------------------

locals {
  region     = data.aws_region.current.id
  partition  = data.aws_partition.current.partition
  account_id = data.aws_caller_identity.current.account_id

  # Derive OIDC provider ARN from EKS cluster when not explicitly provided
  eks_oidc_issuer_url = replace(
    data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", ""
  )
  eks_oidc_provider_arn = var.eks_oidc_provider_arn != "" ? var.eks_oidc_provider_arn : (
    local.needs_irsa
    ? data.aws_iam_openid_connect_provider.eks[0].arn
    : "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
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

  amp_workspace_endpoint = local.is_amp_flavor ? (
    "https://aps-workspaces.${local.region}.amazonaws.com/workspaces/${local.amp_workspace_id}/"
  ) : null

  # CloudWatch OTLP endpoints — base URLs only, otlphttp appends /v1/{signal}
  cw_metrics_endpoint = var.cloudwatch_metrics_endpoint != "" ? var.cloudwatch_metrics_endpoint : (
    "https://monitoring.${local.region}.amazonaws.com"
  )
  cw_traces_endpoint = var.cloudwatch_traces_endpoint != "" ? var.cloudwatch_traces_endpoint : (
    "https://xray.${local.region}.amazonaws.com"
  )
  cw_logs_endpoint = var.cloudwatch_logs_endpoint != "" ? var.cloudwatch_logs_endpoint : (
    "https://logs.${local.region}.amazonaws.com"
  )
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
  # AMP dashboards (original — use recording rules, cluster label)
  amp_dashboard_sources = {
    cluster             = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/cluster.json"
    kubelet             = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/kubelet.json"
    namespace-workloads = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/namespace-workloads.json"
    node-exporter       = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/nodeexporter-nodes.json"
    nodes               = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/nodes.json"
    workloads           = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/${var.dashboard_git_tag}/artifacts/grafana-dashboards/eks/infrastructure/workloads.json"
  }

  # CloudWatch OTLP dashboards (uses @resource.k8s.cluster.name, @aws.account, no recording rules)
  cw_dashboard_sources = {
    cluster             = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/cluster.json"
    containers          = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/containers.json"
    gpu-fleet           = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/gpu-fleet.json"
    kubelet             = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/kubelet.json"
    namespace-workloads = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/namespace-workloads.json"
    node-exporter       = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/nodeexporter-nodes.json"
    nodes               = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/nodes.json"
    unified-service     = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/unified-service.json"
    workloads           = "https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/${var.dashboard_git_tag}/dashboards/cloudwatch-otlp/workloads.json"
  }

  default_dashboard_sources = local.is_cloudwatch_otlp ? local.cw_dashboard_sources : local.amp_dashboard_sources

  dashboard_sources = length(var.dashboard_sources) > 0 ? var.dashboard_sources : local.default_dashboard_sources

  # Dashboards are provisioned only when delivery method is terraform AND enable_dashboards is true
  provision_dashboards = var.dashboard_delivery_method == "terraform" && var.enable_dashboards
}

#--------------------------------------------------------------
# Default Scrape Configs (AMP profiles only)
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
# Self-Managed AMP — OTel Collector Values
#--------------------------------------------------------------

locals {
  self_managed_amp_otel_collector_values = local.is_self_managed_amp ? yamlencode({
    mode = "deployment"

    image = {
      repository = "otel/opentelemetry-collector-contrib"
    }

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
        jaeger = null
        zipkin = null
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

  # Profile-driven OTel Collector values (only self-managed-amp uses OTel Helm)
  otel_collector_values = local.is_self_managed_amp ? local.self_managed_amp_otel_collector_values : ""
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

#--------------------------------------------------------------
# CWA OTLP Gateway Config (cloudwatch-otlp + enable_otlp_gateway)
#--------------------------------------------------------------

locals {
  otlp_gateway_name      = "cwa-otlp-gateway"
  otlp_gateway_namespace = var.cw_agent_namespace

  # EKS add-on images are hosted in an AWS-managed ECR account per region
  eks_ecr_account = "602401143452"
  cwa_agent_image        = "${local.eks_ecr_account}.dkr.ecr.${local.region}.amazonaws.com/eks/observability/cloudwatch-agent:${var.cw_agent_image_tag}"

  otlp_gateway_config = local.needs_otlp_gateway ? jsonencode({
    agent = { region = local.region }
  }) : ""

  otlp_gateway_otel_config = local.needs_otlp_gateway ? yamlencode({
    extensions = {
      "sigv4auth/cw" = {
        region  = local.region
        service = "monitoring"
      }
    }
    receivers = {
      otlp = {
        protocols = {
          grpc = { endpoint = "0.0.0.0:4315" }
          http = { endpoint = "0.0.0.0:4316" }
        }
      }
    }
    processors = {
      batch = {
        send_batch_max_size = 500
        send_batch_size     = 500
        timeout             = "10s"
      }
    }
    exporters = {
      "otlphttp/cw" = {
        auth     = { authenticator = "sigv4auth/cw" }
        endpoint = "${local.cw_metrics_endpoint}:443"
        tls      = { insecure = false }
      }
    }
    service = {
      extensions = ["sigv4auth/cw"]
      pipelines = {
        "metrics/otlp" = {
          receivers  = ["otlp"]
          processors = ["batch"]
          exporters  = ["otlphttp/cw"]
        }
      }
    }
  }) : ""
}
