# deploys collector
module "helm_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.13.1"

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
      name  = "ekscluster"
      value = local.context.eks_cluster_id
    },
    {
      name  = "accountId"
      value = local.context.aws_caller_identity_account_id
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
      name  = "scrapeSampleLimit"
      value = var.prometheus_config.scrape_sample_limit
    }
  ]

  irsa_config = {
    create_kubernetes_namespace       = try(var.helm_config["create_namespace"], true)
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.helm_config.service_account, local.name)
    irsa_iam_policies                 = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }

  addon_context = local.context
}

resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count = var.enable_recording_rules ? 1 : 0

  name         = "accelerator-java-rules"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: default-metric
    rules:
      - record: metric:recording_rule
        expr: avg(rate(container_cpu_usage_seconds_total[5m]))
EOF
}

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-java-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: default-alert
    rules:
      - alert: metric:alerting_rule
        expr: jvm_memory_bytes_used{job="java", area="heap"} / jvm_memory_bytes_max * 100 > 80
        for: 1m
        labels:
            severity: warning
        annotations:
            summary: "JVM heap warning"
            description: "JVM heap of instance `{{$labels.instance}}` from application `{{$labels.application}}` is above 80% for one minute. (current=`{{$value}}%`)"
EOF
}

resource "grafana_dashboard" "this" {
  folder      = var.dashboards_folder_id
  config_json = file("${path.module}/dashboards/default.json")
}
