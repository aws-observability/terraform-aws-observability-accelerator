variable "identitystore_admins_info" {
  description = "The minimum required data to create aws identity store users with admin access to the grafana workspace"
  type = list(object({
    first_name = string
    last_name  = string
    email      = string
  }))

}

variable "identity_store_id" {
  description = "OPTIONAL ID for identity store"
  default     = ""
  type        = string
}

variable "grafana_workspace_name" {
  description = "The logical name of the AMG workspace"
  default     = "aws-observability-accelerator-workshop-workspace"
  type        = string
}
