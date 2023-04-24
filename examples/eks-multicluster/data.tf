data "aws_eks_cluster_auth" "eks_cluster_1" {
  name = var.eks_cluster_1_id
}

data "aws_eks_cluster_auth" "eks_cluster_2" {
  name = var.eks_cluster_2_id
}

data "aws_eks_cluster" "eks_cluster_1" {
  name = var.eks_cluster_1_id
}

data "aws_eks_cluster" "eks_cluster_2" {
  name = var.eks_cluster_2_id
}
