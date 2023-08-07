output "cluster-one-login" {
    description = "Use this command to setup kubeconfig for EKS cluster 1"
    value       = "aws eks update-kubeconfig --name ${var.cluster_one.name} --region ${var.cluster_one.region} --role-arn ${var.cluster_one.tf_role}"
}

output "cluster-two-login" {
    description = "Use this command to setup kubeconfig for EKS cluster 2"
    value       = "aws eks update-kubeconfig --name ${var.cluster_two.name} --region ${var.cluster_two.region} --role-arn ${var.cluster_two.tf_role}"
}

output "amp_workspace_id" {
  description   = "Identifier of the AMP workspace"
  value         = module.managed-service-prometheus.workspace_id
}

output "amg_workspace_arn" {
  description   = "Identifier of the AMG workspace"
  value         = module.managed-service-prometheus.workspace_arn
}

output "amg_workspace_endpoint" {
  description   = "AMG workspace endpoint URL"
  value         = module.managed-service-grafana.workspace_endpoint
}