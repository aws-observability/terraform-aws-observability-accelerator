provider "aws" {
  region = local.region
}


locals {
  name   = basename(path.cwd)
  region = var.aws_region

  vpc_cidr = "10.0.0.0/16"
  //azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    GithubRepo = "github.com/aws-ia/terraform-aws-observability-accelerator"
  }
}
