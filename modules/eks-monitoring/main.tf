module "operator" {
  source = "./add-ons/adot-operator"
  count  = var.enable_amazon_eks_adot ? 1 : 0

  enable_cert_manager = var.enable_cert_manager
  kubernetes_version  = local.eks_cluster_version
  addon_context       = local.context
}

resource "helm_release" "kube_state_metrics" {
  count            = var.enable_kube_state_metrics ? 1 : 0
  chart            = var.ksm_config.helm_chart_name
  create_namespace = var.ksm_config.create_namespace
  namespace        = var.ksm_config.k8s_namespace
  name             = var.ksm_config.helm_release_name
  version          = var.ksm_config.helm_chart_version
  repository       = var.ksm_config.helm_repo_url

  dynamic "set" {
    for_each = var.ksm_config.helm_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "prometheus_node_exporter" {
  count            = var.enable_node_exporter ? 1 : 0
  chart            = var.ne_config.helm_chart_name
  create_namespace = var.ne_config.create_namespace
  namespace        = var.ne_config.k8s_namespace
  name             = var.ne_config.helm_release_name
  version          = var.ne_config.helm_chart_version
  repository       = var.ne_config.helm_repo_url

  dynamic "set" {
    for_each = var.ne_config.helm_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "fluxcd" {
  count            = var.enable_fluxcd ? 1 : 0
  chart            = var.flux_config.helm_chart_name
  create_namespace = var.flux_config.create_namespace
  namespace        = var.flux_config.k8s_namespace
  name             = var.flux_config.helm_release_name
  version          = var.flux_config.helm_chart_version
  repository       = var.flux_config.helm_repo_url

  dynamic "set" {
    for_each = var.flux_config.helm_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "grafana_operator" {
  count            = var.enable_grafana_operator ? 1 : 0
  chart            = var.go_config.helm_chart
  name             = var.go_config.helm_name
  namespace        = var.go_config.k8s_namespace
  version          = var.go_config.helm_chart_version
  create_namespace = var.go_config.create_namespace
  max_history      = 3
}

module "helm_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.32.1"

  helm_config = merge(
    {
      name        = local.name
      chart       = "${path.module}/otel-config"
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
      name  = "assumeRoleArn"
      value = var.managed_prometheus_cross_account_role
    },
    {
      name  = "ekscluster"
      value = local.context.eks_cluster_id
    },
    {
      name  = "globalScrapeInterval"
      value = var.prometheus_config.global_scrape_interval
    },
    {
      name  = "globalScrapeTimeout"
      value = var.prometheus_config.global_scrape_timeout
    },
    {
      name  = "adotLoglevel"
      value = var.adot_loglevel
    },
    {
      name  = "accountId"
      value = local.context.aws_caller_identity_account_id
    },
    {
      name  = "enableTracing"
      value = var.enable_tracing
    },
    {
      name  = "otlpHttpEndpoint"
      value = var.tracing_config.otlp_http_endpoint
    },
    {
      name  = "otlpGrpcEndpoint"
      value = var.tracing_config.otlp_grpc_endpoint
    },
    {
      name  = "tracingTimeout"
      value = var.tracing_config.timeout
    },
    {
      name  = "tracingSendBatchSize"
      value = var.tracing_config.send_batch_size
    },
    {
      name  = "enableCustomMetrics"
      value = var.enable_custom_metrics
    },
    {
      name  = "customMetrics"
      value = yamlencode(var.custom_metrics_config)
    },
    {
      name  = "enableJava"
      value = var.enable_java
    },
    {
      name  = "javaScrapeSampleLimit"
      value = try(var.java_config.scrape_sample_limit, local.java_pattern_config.scrape_sample_limit)
    },
    {
      name  = "javaPrometheusMetricsEndpoint"
      value = try(var.java_config.prometheus_metrics_endpoint, local.java_pattern_config.prometheus_metrics_endpoint)
    },
    {
      name  = "enableAPIserver"
      value = var.enable_apiserver_monitoring
    },
    {
      name  = "enableNginx"
      value = var.enable_nginx
    },
    {
      name  = "nginxScrapeSampleLimit"
      value = try(var.nginx_config.scrape_sample_limit, local.nginx_pattern_config.scrape_sample_limit)
    },
    {
      name  = "nginxPrometheusMetricsEndpoint"
      value = try(var.nginx_config.prometheus_metrics_endpoint, local.nginx_pattern_config.prometheus_metrics_endpoint)
    },
    {
      name  = "enableIstio"
      value = var.enable_istio
    },
    {
      name  = "istioScrapeSampleLimit"
      value = try(var.istio_config.scrape_sample_limit, local.istio_pattern_config.scrape_sample_limit)
    },
    {
      name  = "istioPrometheusMetricsEndpoint"
      value = try(var.istio_config.prometheus_metrics_endpoint, local.istio_pattern_config.prometheus_metrics_endpoint)
    },
    {
      name  = "enableAdotcollectorMetrics"
      value = var.enable_adotcollector_metrics
    }

  ]

  irsa_config = {
    create_kubernetes_namespace       = true
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.helm_config.service_account, local.name)
    irsa_iam_policies = flatten([
      "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
      "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSXrayWriteOnlyAccess",
      var.irsa_iam_additional_policies,
    ])
  }

  addon_context = local.context

  depends_on = [module.operator]
}

module "java_monitoring" {
  source = "./patterns/java"
  count  = var.enable_java ? 1 : 0

  pattern_config = coalesce(var.java_config, local.java_pattern_config)
}

module "nginx_monitoring" {
  source = "./patterns/nginx"
  count  = var.enable_nginx ? 1 : 0

  pattern_config = coalesce(var.nginx_config, local.nginx_pattern_config)
}

module "istio_monitoring" {
  source = "./patterns/istio"
  count  = var.enable_istio ? 1 : 0

  pattern_config = coalesce(var.istio_config, local.istio_pattern_config)
}

module "fluentbit_logs" {
  source = "./add-ons/aws-for-fluentbit"
  count  = var.enable_logs ? 1 : 0

  cw_log_retention_days = var.logs_config.cw_log_retention_days
  addon_context         = local.context
}

module "external_secrets" {
  source = "./add-ons/external-secrets"
  count  = var.enable_external_secrets ? 1 : 0

  enable_external_secrets = var.enable_external_secrets
  grafana_api_key         = var.grafana_api_key
  addon_context           = local.context
  target_secret_namespace = var.target_secret_namespace
  target_secret_name      = var.target_secret_name

  depends_on = [resource.helm_release.grafana_operator]
}
