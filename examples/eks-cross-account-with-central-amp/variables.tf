variable "cluster_one" {
  description = "Input for your first EKS Cluster"
  type        = map
  default     = {
    name      = "hack-eks-1"
    version   = "1.27"
    region    = "us-east-1"
    tf_role   = "<terraform-role-account-1>"
  }
}

variable "cluster_two" {
  description = "Input for your second EKS Cluster"
  type        = map
  default     = {
    name      = "hack-eks-2"
    version   = "1.27"
    region    = "us-east-1"
    tf_role   = "<terraform-role-account-2>"
  }
}

variable "monitoring" {
  description = "Input for your AMP and AMG workspaces"
  type = map
  default     = {
    region                    = "us-east-1"
    amp_name                  = "hack-amp"
    amg_name                  = "hack-amg"
    amg_version               = "9.4"
    enable_grafana_dashboards = true
    grafana_enterprise        = false
    tf_role                   = "<terraform-role-account-3>"
  }
}