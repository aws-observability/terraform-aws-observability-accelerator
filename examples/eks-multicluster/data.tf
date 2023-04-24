data "aws_eks_cluster_auth" "primary" {
  name = var.primary_eks_cluster.id
}

data "aws_eks_cluster_auth" "secondary" {
  name = var.secondary_eks_cluster.id
}

data "aws_eks_cluster" "primary" {
  name = var.primary_eks_cluster.id
}

data "aws_eks_cluster" "secondary" {
  name = var.secondary_eks_cluster.id
}
