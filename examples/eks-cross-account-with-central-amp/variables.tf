variable "cluster_one" {
  description = "Input for your first EKS Cluster"
  type = object({
    name    = string
    version = string
    region  = string
    tf_role = string
  })
  default = {
    name    = "hackathon-eks-1"
    version = "1.27"
    region  = "us-east-1"
    tf_role = "<terraform-role-account-1>"
  }
}

variable "cluster_two" {
  description = "Input for your second EKS Cluster"
  type = object({
    name    = string
    version = string
    region  = string
    tf_role = string
  })
  default = {
    name    = "hackathon-eks-2"
    version = "1.27"
    region  = "us-east-1"
    tf_role = "<terraform-role-account-2>"
  }
}

variable "monitoring" {
  description = "Input for your AMP and AMG workspaces"
  type = object({
    region      = string
    amp_name    = string
    amg_name    = string
    amg_version = string
    tf_role     = string
  })
  default = {
    region              = "us-east-1"
    amp_name            = "amp-hackathon"
    amg_name            = "amg-hackathon"
    amg_version         = "9.4"
    tf_role             = "<terraform-role-account-3>"
  }
}