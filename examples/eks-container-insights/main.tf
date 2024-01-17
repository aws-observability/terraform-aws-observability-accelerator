module "eks_container_insights" {
  source                                    = "../../modules/eks-container-insights"
  cluster_name                              = var.cluster_name
  enable_amazon_eks_cw_observability        = true
  create_cloudwatch_observability_irsa_role = true
  eks_oidc_provider_arn                     = local.addon_context.eks_oidc_provider_arn
}
