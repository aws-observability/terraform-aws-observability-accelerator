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
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
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
      annotations = {
        "eks.amazonaws.com/role-arn" = try(module.collector_irsa_role[0].iam_role_arn, "")
      }
    }

    config = {
      extensions = {
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
      }

      processors = {
        batch = {}
      }

      exporters = {
        "otlphttp/metrics" = {
          endpoint = var.cloudwatch_metrics_endpoint
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
        extensions = ["sigv4auth/monitoring", "sigv4auth/xray", "sigv4auth/logs"]
        pipelines = {
          metrics = {
            receivers  = ["prometheus", "otlp"]
            processors = ["batch"]
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

  # Profile-driven OTel Collector values — currently only cloudwatch-otlp;
  # self-managed-amp branch will be added in task 5.3.
  otel_collector_values = local.is_cloudwatch_otlp ? local.cloudwatch_otel_collector_values : ""
}
