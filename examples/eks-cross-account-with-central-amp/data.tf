data "aws_eks_cluster_auth" "eks_one" {
  name     = var.cluster_one.name
  provider = aws.eks_cluster_one
}

data "aws_eks_cluster_auth" "eks_two" {
  name     = var.cluster_two.name
  provider = aws.eks_cluster_two
}

data "aws_eks_cluster" "eks_one" {
  name     = var.cluster_one.name
  provider = aws.eks_cluster_one
}

data "aws_eks_cluster" "eks_two" {
  name     = var.cluster_two.name
  provider = aws.eks_cluster_two
}
