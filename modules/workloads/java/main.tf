
locals {
  name      = "adot-collector-java"
  namespace = try(var.helm_config.namespace, local.name)
}

data "aws_partition" "current" {}


# deploys collector
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
      value = "${var.amp_endpoint}api/v1/remote_write"
    },
    {
      name  = "region"
      value = var.amp_region
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
    create_kubernetes_namespace       = try(var.helm_config["create_namespace"], true)
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = try(var.helm_config.service_account, local.name)
    irsa_iam_policies                 = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"]
  }

  addon_context = var.addon_context
}


resource "aws_prometheus_rule_group_namespace" "this" {
  count = var.enable_recording_rules ? 1 : 0

  name         = "java_rules"
  workspace_id = var.amp_id
  data         = <<EOF
groups:
  - name: default-metric
    rules:
      - record: metric:recording_rule
        expr: avg(rate(container_cpu_usage_seconds_total[5m]))
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

# dashboard

# resource "grafana_folder" "this" {
#   title = "Observability Accelerator - Java"
# }

# resource "grafana_dashboard" "this" {
#   folder      = grafana_folder.this.id
#   config_json = file("${path.module}/dashboards/default.json")
# }
