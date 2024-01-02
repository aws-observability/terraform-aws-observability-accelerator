provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

locals {
  region               = var.aws_region
  eks_cluster_endpoint = data.aws_eks_cluster.this.endpoint
  create_new_workspace = var.managed_prometheus_workspace_id == "" ? true : false
  istio_chart_url      = "https://tis.tetrate.io/charts"
  istio_chart_version  = "1.20.1"
  istio_global_tag     = "1.20.1-tetrate0"
  istio_global_hub     = "containers.istio.tetratelabs.com"
  tags = {
    Source = "github.com/aws-observability/terraform-aws-observability-accelerator"
  }
}

# deploys the base module
module "aws_observability_accelerator" {
  source = "../../"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator?ref=v2.0.0"

  aws_region = var.aws_region

  # creates a new Amazon Managed Prometheus workspace, defaults to true
  enable_managed_prometheus = local.create_new_workspace

  # reusing existing Amazon Managed Prometheus if specified
  managed_prometheus_workspace_id = var.managed_prometheus_workspace_id

  # sets up the Amazon Managed Prometheus alert manager at the workspace level
  enable_alertmanager = true

  # reusing existing Amazon Managed Grafana workspace
  managed_grafana_workspace_id = var.managed_grafana_workspace_id

  tags = local.tags
}

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = var.eks_cluster_id
  cluster_endpoint  = data.aws_eks_cluster.this.endpoint
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
  cluster_version   = data.aws_eks_cluster.this.version

  # Add-ons
  enable_metrics_server               = true
  enable_cluster_autoscaler          = true
  enable_aws_load_balancer_controller = true

  tags = local.tags
}

################################################################################
# Istio
################################################################################

resource "helm_release" "istio_base" {
  repository       = local.istio_chart_url
  chart            = "base"
  name             = "istio-base"
  namespace        = "istio-system"
  create_namespace = true
  version          = local.istio_chart_version
  wait             = false
  
  set {
    name  = "global.tag"
    value = local.istio_global_tag
  }
  
  set {
    name  = "global.hub"
    value = local.istio_global_hub
  }

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "helm_release" "istiod" {
  repository = local.istio_chart_url
  chart      = "istiod"
  name       = "istiod"
  namespace  = "istio-system"
  version    = local.istio_chart_version
  wait       = false
  
  set {
    name  = "global.tag"
    value = local.istio_global_tag
  }
  
  set {
    name  = "global.hub"
    value = local.istio_global_hub
  }

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  repository = local.istio_chart_url
  chart      = "istio-ingress"
  name       = "istio-ingress"
  namespace  = "istio-system"
  version    = local.istio_chart_version
  wait       = false
  
  set {
    name  = "global.tag"
    value = local.istio_global_tag
  }
  
  set {
    name  = "global.hub"
    value = local.istio_global_hub
  }
  
  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  
  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  depends_on = [
    helm_release.istiod
  ]
}

module "eks_monitoring" {
  source = "../../modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"
  enable_istio   = true
  eks_cluster_id = var.eks_cluster_id

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  # deploys external-secrets in to the cluster
  enable_external_secrets = true
  grafana_api_key         = var.grafana_api_key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  # control the publishing of dashboards by specifying the boolean value for the variable 'enable_dashboards', default is 'true'
  enable_dashboards = var.enable_dashboards

  managed_prometheus_workspace_id = module.aws_observability_accelerator.managed_prometheus_workspace_id

  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  enable_logs = true

  tags = local.tags

  depends_on = [
    module.aws_observability_accelerator
  ]
}
