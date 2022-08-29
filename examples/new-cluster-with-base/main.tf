provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    t3_l = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]
      min_size        = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}


module "observability_accelerator" {
  source = "../../"

  aws_region = local.region
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  enable_alertmanager = true
  enable_managed_grafana = false

  managed_grafana_workspace_id = var.managed_grafana_workspace_id
  managed_grafana_region = var.managed_grafana_region

  grafana_api_key = var.grafana_api_key

  tags = {
    Source = "aws-observability-accelerator"
  }
}

module "infra" {
  source = "../../modules/workloads/infra"

  dashboards_folder_id = module.observability_accelerator.dashboards_folder_id
  eks_cluster_id = module.eks_blueprints.eks_cluster_id
  enable_alerting_rules = false

  managed_prometheus_workspace_id = module.observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_region = module.observability_accelerator.managed_prometheus_workspace_region

  tags = {
    Source = "aws-observability-accelerator"
  }
}

