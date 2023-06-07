terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.25.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3.0"
    }
  }
}
