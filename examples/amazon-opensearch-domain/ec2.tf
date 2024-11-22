data "aws_ami" "reverse_proxy" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "reverse_proxy" {
  name        = "reverse_proxy"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "reverse_proxy"
  }
}

resource "aws_vpc_security_group_ingress_rule" "reverse_proxy_ipv4" {
  security_group_id = aws_security_group.reverse_proxy.id
  cidr_ipv4         = local.reverse_proxy_client_ip
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.reverse_proxy.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_launch_configuration" "reverse_proxy" {
  image_id                    = data.aws_ami.reverse_proxy.id
  instance_type               = "t2.medium"
  associate_public_ip_address = false
  user_data                   = templatefile("${path.module}/user_data.sh", { os_domain = module.opensearch.domain_endpoint })
  security_groups             = [aws_security_group.reverse_proxy.id]
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens = "required"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "reverse_proxy" {
  name                 = aws_launch_configuration.reverse_proxy.name
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.reverse_proxy.name
  vpc_zone_identifier  = [local.public_subnet_id]
  lifecycle {
    create_before_destroy = true
  }
}
