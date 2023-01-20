variable "identitystore_admins_info" {
  description = "The minimum required data to create aws identity store users with admin access to the grafana workspace"
  type = list(object({
    first_name = string
    last_name  = string
    email      = string
  }))

}
