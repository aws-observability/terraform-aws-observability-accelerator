provider "kubernetes" {
    host = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", local.addon_context.eks_cluster_id]
        command     = "aws"
    }
 }

provider "helm" {
    kubernetes {
    host = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", local.addon_context.eks_cluster_id]
        command     = "aws"
    }
 }
}

module "helm_addon" {
  source            = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.32.0"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = local.addon_context
}

resource "aws_iam_policy" "adot-exporter-for-eks-on-ec2" {
  name        = "${local.addon_context.eks_cluster_id}-adot"
  description = "IAM Policy for ADOT on AWS"
  policy      = data.aws_iam_policy_document.irsa.json
  tags        = local.addon_context.tags
}