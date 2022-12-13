# Existing Managed Prometheus Workspace Observability Pattern

This example demonstrates how to use the AWS Observability Accelerator Terraform
modules with Amazon Managed Prometheus (AMP) workspace monitoring enabled.

The current example deploys a dashboard into an existing Amazon Managed Grafana (AMG) workspace to provide observability over an existing AMP workspace. It also deploys CloudWatch alarms for AMP usage service limits.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

It is also required to have existing AMP and Grafana workspaces. These could be created through the [other example modules](../) in this repository.

## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation

1. **Clone the repo using the command below**

```sh
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
```

2. **Initialize terraform**

```sh
cd examples/amp-monitoring
terraform init
```

3. **AWS Region**

Specify the AWS Region where the resources will be deployed. Edit the `terraform.tfvars` file and modify `aws_region="..."`. You can also use environement variables `export TF_VAR_aws_region=xxx`.

4. **Amazon Managed Service for Prometheus workspace**

If you have an existing workspace, add `managed_prometheus_workspace_id=ws-xxx`
or use an environment variable `export TF_VAR_managed_prometheus_workspace_id=ws-xxx`.

If you would like to create CloudWatch alarms for multiple workspaces in a region you can pass them in a comma seperated string.

`managed_prometheus_workspace_id = "ws-xxx,ws-xxx"`

You can use the following export command to create alarms for all of the workspaces in a region.

```sh
export TF_VAR_managed_prometheus_workspace_id=$(aws amp list-workspaces --query 'workspaces[].workspaceId' --output text |  sed -E 's/\t/,/g')
```

5. **Amazon Managed Grafana workspace**

Use an existing workspace, add `managed_grafana_workspace_id=g-xxx`
or use an environment variable `export TF_VAR_managed_grafana_workspace_id=g-xxx`.

6. <a name="apikey"></a> **Grafana API Key**

Amazon Managed Service for Grafana provides a control plane API for generating Grafana API keys. We will provide to Terraform
a short lived API key to run the `apply` or `destroy` command.
Ensure you have necessary IAM permissions (`CreateWorkspaceApiKey, DeleteWorkspaceApiKey`)

```sh
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 1200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

```sh
terraform apply -var-file=terraform.tfvars
```

or if you had only setup environment variables, run

```sh
terraform apply
```

## Visualization

1. **Cloudwatch datasource on Grafana**

Open your Grafana workspace and under Configuration -> Data sources, you should see `aws-observability-accelerator-cloudwatch`. Open and click `Save & test`. You should see a notification confirming that the CloudWatch datasource is ready to be used on Grafana.

2. **Grafana dashboards**

Go to the Dashboards panel of your Grafana workspace. You should see a list of dashboards under the `AMP Monitoring Dashboards` folder.

Open the `AMP Accelerator Dashboard` to see a visualization of the AMP workspace.

<img width="1786" alt="Screen Shot 2022-10-11 at 2 16 17 PM" src="https://user-images.githubusercontent.com/97046295/196742772-fba1a5fb-dd38-445c-88a9-607f38994713.png">

3. **Amazon Managed Service for Prometheus CloudWatch Alarms.**

Open the CloudWatch console and click `Alarms` > `All Alarms` to review the service limit alarms.

<img width="1525" alt="image" src="https://user-images.githubusercontent.com/97046295/196742923-876e3b1c-6f2a-419d-ad39-9c057a0f7650.png">

In us-east-1 region an alarm is created for billing. This alarm utilizes anomaly detection to detect anomalies in the Estimated Charges billing metric.

<img width="1346" alt="image" src="https://user-images.githubusercontent.com/97046295/197042518-a98d69df-8f53-4a4a-afb8-f424d91da56f.png">



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0, < 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.36.1 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 1.30.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amp_monitor"></a> [amp\_monitor](#module\_amp\_monitor) | ../../modules/workloads/amp-monitoring | n/a |
| <a name="module_billing"></a> [billing](#module\_billing) | ../../modules/Billing | n/a |

## Resources

| Name | Type |
|------|------|
| [grafana_folder.this](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/grafana_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | n/a | yes |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | Amazon Managed Grafana (AMG) workspace ID | `string` | n/a | yes |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Service for Prometheus Workspace ID to create Alarms for | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_dashboards_folder_id"></a> [grafana\_dashboards\_folder\_id](#output\_grafana\_dashboards\_folder\_id) | Grafana folder ID for automatic dashboards. Required by workload modules |
<!-- END_TF_DOCS -->
