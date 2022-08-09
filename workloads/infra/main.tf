
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.24.0"
    }
  }
}

provider "grafana" {
  url  = var.managed_grafana_workspace_endpoint
  auth = var.grafana_api_key
}

resource "helm_release" "kube_state_metrics" {
  count            = var.config.enable_kube_state_metrics ? 1 : 0
  chart            = var.config.ksm_helm_chart_name
  create_namespace = var.config.kms_create_namespace
  namespace        = var.config.ksm_k8s_namespace
  name             = var.config.ksm_helm_release_name
  version          = var.config.ksm_helm_chart_version
  repository       = var.config.ksm_helm_repo_url

  dynamic "set" {
    for_each = var.config.ksm_helm_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "prometheus_node_exporter" {
  count            = var.config.enable_node_exporter ? 1 : 0
  chart            = var.config.ne_helm_chart_name
  create_namespace = var.config.ne_create_namespace
  namespace        = var.config.ne_k8s_namespace
  name             = var.config.ne_helm_release_name
  version          = var.config.ne_helm_chart_version
  repository       = var.config.ne_helm_repo_url

  dynamic "set" {
    for_each = var.config.ne_helm_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

module "helm_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons/helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/otel-config"
      version     = "0.2.0"
      namespace   = local.namespace
      description = "ADOT helm Chart deployment configuration"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "ampurl"
      value = "${var.managed_prometheus_workspace_endpoint}api/v1/remote_write"
    },
    {
      name  = "region"
      value = var.managed_prometheus_workspace_region
    },
    {
      name  = "prometheusMetricsEndpoint"
      value = "metrics"
    },
    {
      name  = "prometheusMetricsPort"
      value = 8888
    },
    {
      name  = "scrapeInterval"
      value = "15s"
    },
    {
      name  = "scrapeTimeout"
      value = "10s"
    },
    {
      name  = "scrapeSampleLimit"
      value = 1000
    }
  ]

  irsa_config = {
    create_kubernetes_namespace       = true
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.config.helm_config.service_account, local.name)
    irsa_iam_policies                 = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }

  addon_context = local.context
}
