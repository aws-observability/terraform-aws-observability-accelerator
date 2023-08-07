###########################################################################
#                      EKS resources for account 1                        #
###########################################################################

module "eks-one" {
  source    = "terraform-aws-modules/eks/aws"
  version   = "19.15.3"
  providers = {
    aws     = aws.eks_cluster_one
  }

  cluster_name                    = var.cluster_one.name
  cluster_version                 = var.cluster_one.version

  vpc_id                          = module.vpc-one.vpc_id
  subnet_ids                      = module.vpc-one.private_subnets
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name                        = "ng-1"

      instance_types              = ["m5.large"]

      min_size                    = 0
      max_size                    = 9
      desired_size                = 3
    }
  }
}

module "eks_blueprints_addons_one" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.3"
  providers = {
    aws     = aws.eks_cluster_one
    helm    = helm.eks_cluster_one
  }

  cluster_name      = module.eks-one.cluster_name
  cluster_endpoint  = module.eks-one.cluster_endpoint
  cluster_version   = module.eks-one.cluster_version
  oidc_provider_arn = module.eks-one.oidc_provider_arn

  #---------------------------------------#
  # Amazon EKS Managed Add-ons            #
  #---------------------------------------#
  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa_one.iam_role_arn
    }
    coredns = {
      preserve = true
    }
    vpc-cni = {
      preserve = true
    }
    kube-proxy = {
      preserve = true
    }
  }
}

#---------------------------------------#
# EKS Monitoring Addon for cluster one  #
#---------------------------------------#
module "eks_monitoring_one" {
  source = "../../modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"
  providers = {
    aws     = aws.eks_cluster_one
    helm    = helm.eks_cluster_one
    kubernetes = kubernetes.eks_cluster_one
    kubectl = kubectl.eks_cluster_one
  }

  eks_cluster_id = var.cluster_one.name

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  enable_alerting_rules = false
  enable_recording_rules = false

  # deploys external-secrets in to the cluster
  enable_external_secrets = true
  grafana_api_key         = aws_grafana_workspace_api_key.key.key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  # control the publishing of dashboards by specifying the boolean value for the variable 'enable_dashboards', default is 'true'
  enable_dashboards = var.monitoring.enable_grafana_dashboards

  managed_prometheus_workspace_id = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region
  managed_prometheus_cross_account_role = aws_iam_role.cross-account-amp-role.arn
  irsa_iam_additional_policies = [aws_iam_policy.irsa_assume_role_policy_one.arn]

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  enable_logs = true

  depends_on = [
    module.aws_observability_accelerator,
    module.eks-one
  ]
}


###########################################################################
#                      EKS resources for account 2                        #
###########################################################################

module "eks-two" {
  source    = "terraform-aws-modules/eks/aws"
  version   = "19.15.3"
  providers = {
    aws     = aws.eks_cluster_two
  }

  cluster_name                    = var.cluster_two.name
  cluster_version                 = var.cluster_two.version

  vpc_id                          = module.vpc-two.vpc_id
  subnet_ids                      = module.vpc-two.private_subnets
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name                        = "ng-1"

      instance_types              = ["m5.large"]

      min_size                    = 0
      max_size                    = 9
      desired_size                = 3
    }
  }
}

module "eks_blueprints_addons_two" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.3"
  providers = {
    aws     = aws.eks_cluster_two
    helm    = helm.eks_cluster_two
  }

  cluster_name      = module.eks-two.cluster_name
  cluster_endpoint  = module.eks-two.cluster_endpoint
  cluster_version   = module.eks-two.cluster_version
  oidc_provider_arn = module.eks-two.oidc_provider_arn

  #---------------------------------------#
  # Amazon EKS Managed Add-ons            #
  #---------------------------------------#
  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa_two.iam_role_arn
    }
    coredns = {
      preserve = true
    }
    vpc-cni = {
      preserve = true
    }
    kube-proxy = {
      preserve = true
    }
  }
}

#---------------------------------------#
# EKS Monitoring Addon for cluster two  #
#---------------------------------------#
module "eks_monitoring_two" {
  source = "../../modules/eks-monitoring"
  # source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v2.0.0"
  providers = {
    aws     = aws.eks_cluster_two
    helm    = helm.eks_cluster_two
    kubernetes = kubernetes.eks_cluster_two
    kubectl = kubectl.eks_cluster_two
  }

  eks_cluster_id = var.cluster_two.name

  # deploys AWS Distro for OpenTelemetry operator into the cluster
  enable_amazon_eks_adot = true

  # reusing existing certificate manager? defaults to true
  enable_cert_manager = true

  enable_alerting_rules = false
  enable_recording_rules = false

  # deploys external-secrets in to the cluster
  enable_external_secrets = true
  grafana_api_key         = aws_grafana_workspace_api_key.key.key
  target_secret_name      = "grafana-admin-credentials"
  target_secret_namespace = "grafana-operator"
  grafana_url             = module.aws_observability_accelerator.managed_grafana_workspace_endpoint

  # control the publishing of dashboards by specifying the boolean value for the variable 'enable_dashboards', default is 'true'
  enable_dashboards = var.monitoring.enable_grafana_dashboards

  managed_prometheus_workspace_id = module.aws_observability_accelerator.managed_prometheus_workspace_id
  managed_prometheus_workspace_endpoint = module.aws_observability_accelerator.managed_prometheus_workspace_endpoint
  managed_prometheus_workspace_region   = module.aws_observability_accelerator.managed_prometheus_workspace_region
  managed_prometheus_cross_account_role = aws_iam_role.cross-account-amp-role.arn
  irsa_iam_additional_policies = [aws_iam_policy.irsa_assume_role_policy_two.arn]

  # optional, defaults to 60s interval and 15s timeout
  prometheus_config = {
    global_scrape_interval = "60s"
    global_scrape_timeout  = "15s"
  }

  enable_logs = true

  depends_on = [
    module.aws_observability_accelerator,
    module.eks-two
  ]
}

###########################################################################
#                  AMP and Grafana resources                              #
###########################################################################

module "managed-service-grafana" {
  source    = "terraform-aws-modules/managed-service-grafana/aws"
  version   = "1.10.0"
  providers = {
    aws     = aws.central_monitoring
  }

  name              = var.monitoring.amg_name
  description       = "Amazon Managed Grafana for centralized prometheus monitoring"
  grafana_version   = var.monitoring.amg_version
  associate_license = var.monitoring.grafana_enterprise
  data_sources      = ["PROMETHEUS"]
}

resource "aws_grafana_workspace_api_key" "key" {
  provider        = aws.central_monitoring
  key_name        = "terraform-key"
  key_role        = "ADMIN"
  seconds_to_live = 86400
  workspace_id    = module.managed-service-grafana.workspace_id
}

module "managed-service-prometheus" {
  source    = "terraform-aws-modules/managed-service-prometheus/aws"
  version   = "2.2.2"
  providers = {
    aws     = aws.central_monitoring
  }

  workspace_alias = var.monitoring.amp_name
}

module "aws_observability_accelerator" {
  source                              = "../../../terraform-aws-observability-accelerator"
  aws_region                          = var.cluster_one.region
  enable_managed_prometheus           = false
  enable_alertmanager                 = false
  managed_prometheus_workspace_region = var.monitoring.region
  managed_prometheus_workspace_id     = module.managed-service-prometheus.workspace_id
  managed_grafana_workspace_id        = module.managed-service-grafana.workspace_id

  providers = {
    aws = aws.central_monitoring
  }
}