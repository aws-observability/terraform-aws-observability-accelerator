

module "eks_observability_accelerator" {
  source = "aws-ia/aws-observability-accelerator/terraform/eks"

  # -- or use an existing cluster
  eks_cluster_id = var.eks_cluster_id

  # enable managed add-on for ADOT. Do we enforce this or let users
  # have their own configs for OTEL operator
  enable_amazon_eks_adot = true

  # -- or enable opentelemetry operator
  enable_open_telemetry_operator = true
  open_telemetry_operator_config = map() // custom config

  # deploy selected workloads by count indexing

  # this creates a new AMP workspace
  create_managed_prometheus_workspace = true

  enable_haproxy = true
  haproxy_config = {
    amp_endpoint     = module / amp.endpoint
    grafana_endpoint = module.grafana.endpoint
  }

  enable_java = true
  java_config = {
    amp_endpoint     = ""
    grafana_endpoint = ""
  }




  # -- or use an existing one
  # seems like https://github.com/terraform-aws-modules/terraform-aws-managed-service-prometheus
  # supports importing
  amp_workspace_alias = var.amp_alias

  # enable rules and alerts
  enable_alert_manager = true

  # -- or provide custom alerts definition
  prometheus_custom_alert_rule = var.prometheus_custom_alert_rule


  # create grafana workspace, and customer to deal with authentication later
  create_managed_grafana_workspace = true
  grafana_auth_provider            = var.grafana_auth_provider       //SAML or AWS_SSO
  grafana_account_access_type      = var.grafana_account_access_type // CURRENT_ACCOUNT or ORGANIZATION
  grafana_permission_type          = var.grafana_permission_type     // SERVICE_MANAGED or CUSTOMER_MANAGED
  grafana_permission_role_arn      = var.grafana_permission_role_arn // if CUSTOMER_MANAGED

  # -- or using existing amg workspace. so we can use API for keys
  managed_grafana_workspace_id = var.managed_grafana_workspace_id

}

module "amp" {

}

module "grafana" {

}