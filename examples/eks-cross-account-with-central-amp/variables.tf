variable "cluster_one" {
  description = "Input for your first EKS Cluster"
  type = object({
    name    = string
    region  = string
    tf_role = string
  })
  default = {
    name    = "eks-cluster-1"
    region  = "us-east-1"
    tf_role = "<iam-role-in-eks-cluster-1-account>"
  }
}

variable "cluster_two" {
  description = "Input for your second EKS Cluster"
  type = object({
    name    = string
    region  = string
    tf_role = string
  })
  default = {
    name    = "eks-cluster-2"
    region  = "us-east-1"
    tf_role = "<iam-role-in-eks-cluster-2-account>"
  }
}

variable "monitoring" {
  description = "Input for your AMP and AMG workspaces"
  type = object({
    managed_grafana_id  = string
    amp_workspace_alias = string
    region              = string
    tf_role             = string
  })
  default = {
    managed_grafana_id  = "<grafana-ws-id>"
    amp_workspace_alias = "aws-observability-accelerator"
    region              = "<grafana-ws-region>"
    tf_role             = "<iam-role-in-grafana-ws-account>"
  }
}
