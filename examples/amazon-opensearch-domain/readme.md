# Amazon OpenSearch Domain Setup

This example creates an Amazon OpenSearch domain in the same VPC of the EKS cluster,
and a proxy instance to Amazon OpenSearch Dashboards, to allow access from outside of the VPC.

Step-by-step instructions available on our [docs site](https://aws-observability.github.io/terraform-aws-observability-accelerator/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | terraform-aws-modules/opensearch/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.reverse_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_configuration.reverse_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.reverse_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.opensearch_master_user_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.opensearch_master_user_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.reverse_proxy_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.opensearch_master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.reverse_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | AZ where the example domain and its proxy instance will be created | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_master_user_name"></a> [master\_user\_name](#input\_master\_user\_name) | OpenSearch domain user name | `string` | `"observability-accelerator"` | no |
| <a name="input_master_user_password"></a> [master\_user\_password](#input\_master\_user\_password) | OpenSearch domain password | `string` | `""` | no |
| <a name="input_reverse_proxy_client_ip"></a> [reverse\_proxy\_client\_ip](#input\_reverse\_proxy\_client\_ip) | CIDR block to grant access for OpenSearch reverse proxy | `string` | `"0.0.0.0/0"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EKS cluster VPC Id | `string` | n/a | yes |
| <a name="input_expose_proxy"></a> [expose\_proxy](#expose\_proxy) | Whether or not to expose EC2 proxy instance for Amazon Opensearch dashboards to the Internet | `string` | false | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs"></a> [cloudwatch\_logs](#output\_cloudwatch\_logs) | Map of CloudWatch log groups created and their attributes |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | The Amazon Resource Name (ARN) of the domain |
| <a name="output_domain_dashboard_endpoint"></a> [domain\_dashboard\_endpoint](#output\_domain\_dashboard\_endpoint) | Domain-specific endpoint for Dashboard without https scheme |
| <a name="output_domain_endpoint"></a> [domain\_endpoint](#output\_domain\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The unique identifier for the domain |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | Map of VPC endpoints created and their attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
