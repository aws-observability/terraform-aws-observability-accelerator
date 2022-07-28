

module "eks_observability_accelerator" {
  #source = "aws-ia/terrarom-aws-observability-accelerator"
  source = "../"

  aws_region     = var.aws_region
  eks_cluster_id = var.eks_cluster_id

  # TODO: create also a cluster, VPC -- check if enough VPCs

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = false

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = false

  # # -- or enable opentelemetry operator
  enable_opentelemetry_operator = false #-- true doesn't work for me, needs fix
  #open_telemetry_operator_config = map() // custom config

  # creates a new AMP workspace, defaults to true
  enable_managed_prometheus = false

  # reusing existing AMP -- needs data source for alerting rules
  managed_prometheus_id     = var.managed_prometheus_workspace_id
  managed_prometheus_region = null # defaults to the current region, useful for cross region scenarios (same account)

  # sets up the AMP alert manager at the workspace level
  enable_alertmanager = true

  # create a new Grafana workspace
  enable_managed_grafana = true
  #managed_grafana_workspace_id = "g-9790a4306b"



  enable_java                 = true
  enable_java_recording_rules = true


  # enable_haproxy = true
  # haproxy_config = {
  #   amp_endpoint     = module / amp.endpoint
  #   grafana_endpoint = module.grafana.endpoint
  # }


  # java_config = {
  #   amp_endpoint     = ""
  #   grafana_endpoint = ""
  # }

  # # -- or provide custom alerts definition
  # prometheus_custom_alert_rule = var.prometheus_custom_alert_rule


  # # create grafana workspace, and customer to deal with authentication later
  # create_managed_grafana_workspace = true
  # grafana_auth_provider            = var.grafana_auth_provider       //SAML or AWS_SSO
  # grafana_account_access_type      = var.grafana_account_access_type // CURRENT_ACCOUNT or ORGANIZATION
  # grafana_permission_type          = var.grafana_permission_type     // SERVICE_MANAGED or CUSTOMER_MANAGED
  # grafana_permission_role_arn      = var.grafana_permission_role_arn // if CUSTOMER_MANAGED

  # # -- or using existing amg workspace. so we can use API for keys


  tags = local.tags


}
# module "amp" {

# }

# module "grafana" {

# }
