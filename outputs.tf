output "eks_cluster_id" {
  description = "EKS Cluster Id"
  value       = var.eks_cluster_id
}

output "aws_region" {
  description = "EKS Cluster Id"
  value       = var.aws_region
}

output "eks_cluster_version" {
  value = data.aws_eks_cluster.eks_cluster.version
}

output "prometheus_endpoint" {
  value = [aws_prometheus_workspace.this.*.prometheus_endpoint]
}

output "prometheus_id" {
  value = [aws_prometheus_workspace.this.*.id]
}
