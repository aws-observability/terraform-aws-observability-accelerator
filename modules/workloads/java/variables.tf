variable "java" {
  default = {
    a = ""
    b = ""
  }
}

variable "amp_endpoint" {
  description = "Managed Prometheus endpoint"
  type        = string
}

variable "amp_id" {
  description = "Managed Prometheus workspace id"
  type        = string
}
