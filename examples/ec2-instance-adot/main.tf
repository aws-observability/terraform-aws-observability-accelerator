provider "aws" {
  region = "us-east-2"
}

#---------------------------------------------------------------
# IAM Resources
#---------------------------------------------------------------
resource "aws_iam_policy" "AWSDistroOpenTelemetryPolicy" {
  name        = "AWSDistroOpenTelemetryPolicy"
  path        = "/"
  description = "Policy used for EC2 instances that use ADOT"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aps:ListWorkspaces",
                "aps:DescribeWorkspace",
                "iam:ListInstanceProfiles",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "ec2:Describe*",
                "ec2:Search*",
                "ec2:Get*",
                "ssm:GetParameters",
                "xray:GetSamplingTargets",
                "xray:GetSamplingRules",
                "xray:GetSamplingStatisticSummaries",
                "xray:PutTelemetryRecords",
                "xray:PutTraceSegments"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role" "AWSDistroOpenTelemetryRole" {
  name = "AWSDistroOpenTelemetryRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSDistroOpenTelemetryRolePolicy-attach" {
  role       = aws_iam_role.AWSDistroOpenTelemetryRole.name
  policy_arn = aws_iam_policy.AWSDistroOpenTelemetryPolicy.arn
}

resource "aws_iam_role_policy_attachment" "AWSDistroOpenTelemetryRole-PrometheusPolicy-attach" {
  role       = aws_iam_role.AWSDistroOpenTelemetryRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

#---------------------------------------------------------------
# Amazon Managed Prometheus Resources
#---------------------------------------------------------------
resource "aws_prometheus_workspace" "AWSDistroOpenTelemetryAMPWorkspace" {
    alias = "AWSDistroOpenTelemetryAMPWorkspace"
}

#---------------------------------------------------------------
# Key Pair
#---------------------------------------------------------------
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ADOTkeypair" {
  key_name   = "ADOTkeypair"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ADOTkeypair.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

# Get the Default VPC
data "aws_vpcs" "vpcs" {}

data "aws_vpc" "DefaultVPC" {
  count = length(data.aws_vpcs.vpcs.ids)
  id    = tolist(data.aws_vpcs.vpcs.ids)[count.index]
}

output "DefaultVPC" {
  value = data.aws_vpc.DefaultVPC[0].id
}

 # Get the first Subnet
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.DefaultVPC[0].id]
  }
}

data "aws_subnet" "DefaultSubnet" {
  count = length(data.aws_subnets.subnets.ids)
  id    = tolist(data.aws_subnets.subnets.ids)[count.index]
}

output "DefaultSubnet" {
  value = data.aws_subnet.DefaultSubnet[0].id
}

# Create the Security Group
resource "aws_security_group" "ADOTEC2SecurityGroup" {
  name        = "ADOTEC2SecurityGroup"
  description = "ADOT EC2 Security Group (Allow SSH inbound traffic)"
  vpc_id      = data.aws_vpc.DefaultVPC[0].id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.your_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DefaultSG"
  }
}
#---------------------------------------------------------------
# EC2 Resources
#---------------------------------------------------------------
resource "aws_iam_instance_profile" "ADOTEC2InstanceProfile" {
  name = "ADOTEC2InstanceProfile"
  role = aws_iam_role.AWSDistroOpenTelemetryRole.name
}

resource "aws_instance" "ADOTEC2TerraformInstance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ADOTEC2SecurityGroup.id]
  subnet_id              = data.aws_subnet.DefaultSubnet[0].id
  key_name = aws_key_pair.ADOTkeypair.key_name

  iam_instance_profile = aws_iam_instance_profile.ADOTEC2InstanceProfile.name

  tags = {
    Name = "ADOTEC2TerraformInstance"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = "3"
  }

  connection {
    host     = self.public_ip
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("${aws_key_pair.ADOTkeypair.key_name}.pem")
  }

  provisioner "file" {
    source      = "node_exporter_setup.sh"
    destination = "/tmp/node_exporter_setup.sh"
  }

  provisioner "file" {
    source      = "configure_adot.sh"
    destination = "/tmp/configure_adot.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_exporter_setup.sh",
      "/tmp/node_exporter_setup.sh",
      "chmod +x /tmp/configure_adot.sh",
      "/tmp/configure_adot.sh",
    ]
  }
}
