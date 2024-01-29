module "eks_container_insights" {
  source                                     = "../../modules/eks-container-insights"
  eks_cluster_id                             = var.eks_cluster_id
  enable_amazon_eks_cw_observability         = true
  create_cloudwatch_observability_irsa_role  = true
  eks_oidc_provider_arn                      = local.addon_context.eks_oidc_provider_arn
  create_cloudwatch_application_signals_role = true
}
