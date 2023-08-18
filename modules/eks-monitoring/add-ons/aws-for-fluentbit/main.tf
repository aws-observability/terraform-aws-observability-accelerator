module "helm_addon" {
  source            = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.32.1"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "aws_for_fluent_bit" {
  name        = "${var.addon_context.eks_cluster_id}-fluentbit"
  description = "IAM Policy for AWS for FluentBit"
  policy      = data.aws_iam_policy_document.irsa.json
  tags        = var.addon_context.tags
}
