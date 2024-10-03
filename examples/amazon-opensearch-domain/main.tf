provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

locals {
  region = var.aws_region
  name   = "aws-o11y-accelerator"

  vpc_cidr                = data.aws_vpc.main.cidr_block
  public_subnet_id        = var.public_subnet_id
  private_subnet_id       = var.private_subnet_id
  azs                     = slice(data.aws_availability_zones.available.names, 0, 3)
  reverse_proxy_client_ip = var.reverse_proxy_client_ip

  tags = {
    GithubRepo = "terraform-aws-observability-accelerator"
    GithubOrg  = "aws-observability"
  }
}

module "opensearch" {
  source = "terraform-aws-modules/opensearch/aws"

  # Domain
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  advanced_security_options = {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true

    master_user_options = {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  cluster_config = {
    instance_count           = 1
    dedicated_master_enabled = false
    instance_type            = "r6g.large.search"

    zone_awareness_enabled = false
  }

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  domain_name = local.name

  ebs_options = {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_type = "gp3"
    volume_size = 20
  }

  encrypt_at_rest = {
    enabled = true
  }

  engine_version = "OpenSearch_2.11"

  node_to_node_encryption = {
    enabled = true
  }

  software_update_options = {
    auto_software_update_enabled = false
  }

  vpc_options = {
    subnet_ids = [local.private_subnet_id]
  }

  # VPC endpoint
  vpc_endpoints = {
    one = {
      subnet_ids = [local.private_subnet_id]
    }
  }

  security_group_rules = {
    ingress_443 = {
      type        = "ingress"
      description = "HTTPS access from VPC"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    }
  }

  # Access policy
  access_policy_statements = [
    {
      effect = "Allow"

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      actions = ["es:*"]
    }
  ]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
