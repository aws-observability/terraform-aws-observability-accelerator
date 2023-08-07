data "aws_availability_zones" "one" {
    provider = aws.eks_cluster_one
}

data "aws_availability_zones" "two" {
    provider = aws.eks_cluster_two
}

module "vpc-one" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "5.0.0"
  providers = {
    aws          = aws.eks_cluster_one
  }

  name                 = "${var.cluster_one.name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.one.names, 0, 3)

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_one.name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_one.name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}

module "vpc-two" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "5.0.0"
  providers = {
    aws          = aws.eks_cluster_two
  }

  name                 = "${var.cluster_two.name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.two.names, 0, 3)

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_two.name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_two.name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}
