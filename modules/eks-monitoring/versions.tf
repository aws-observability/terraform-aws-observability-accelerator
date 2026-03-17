terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    grafana = {
      source                = "grafana/grafana"
      version               = ">= 2.0.0"
      configuration_aliases = [grafana]
    }
  }
}
