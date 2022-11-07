terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.25.0"
    }
  }
}
