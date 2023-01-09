# Monitoring Amazon Managed Service for Prometheus workspaces

This example allows you to monitor your Amazon Managed Service for Prometheus workspaces
using Amazon CloudWatch vended metrics and logs. It also creates configurable CloudWatch
alarms for service usage limits. Those informations are displayed in a Managed Grafana
workspace dashboard.

## Prerequisites

Make sure to complete the [prerequisites section](/terraform-aws-observability-accelerator/concepts/#prerequisites)
before proceeding.

> This example doesn't require an Amazon EKS cluster and Kubernetes tools (ex. `kubectl`).

## Setup


### 1. Download sources and initialize Terraform

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/amp-monitoring
terraform init
```

### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```

### 3. Amazon Managed Service for Prometheus workspace

Specify one or more workspaces in the same Region separated with a comma seperated string.

```bash
export TF_VAR_managed_prometheus_workspace_id="ws-xxx"
```

You can use the following command to create alarms for all of the workspaces in a region.

```sh
export TF_VAR_managed_prometheus_workspace_id=$(aws amp list-workspaces --query 'workspaces[].workspaceId' --output text |  sed -E 's/\t/,/g')
```

### 4. Amazon Managed Grafana workspace

To run this example you need an Amazon Managed Grafana workspace.

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
```

### 5. Grafana API Key

Amazon Managed Grafana provides a control plane API for generating Grafana API keys.
As a security best practice, we will provide to Terraform a short lived API key to
run the `apply` or `destroy` command.

Ensure you have necessary IAM permissions (`CreateWorkspaceApiKey, DeleteWorkspaceApiKey`)

```bash
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 1200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

Simply run this command to deploy the example

```sh
terraform apply
```

## Visualization

### 1. Cloudwatch datasource on Grafana

Open your Grafana workspace and under Configuration -> Data sources, you should see `aws-observability-accelerator-cloudwatch`. Open and click `Save & test`. You should see a notification confirming that the CloudWatch datasource is ready to be used on Grafana.

### 2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You should see a list of dashboards under the `AMP Monitoring Dashboards` folder.

Open the `AMP Accelerator Dashboard` to see a visualization of the AMP workspace.

<img width="1786" alt="Screen Shot 2022-10-11 at 2 16 17 PM" src="https://user-images.githubusercontent.com/97046295/196742772-fba1a5fb-dd38-445c-88a9-607f38994713.png">

### 3. Amazon Managed Service for Prometheus CloudWatch Alarms.

Open the CloudWatch console and click `Alarms` > `All Alarms` to review the service limit alarms.

<img width="1525" alt="image" src="https://user-images.githubusercontent.com/97046295/196742923-876e3b1c-6f2a-419d-ad39-9c057a0f7650.png">

In us-east-1 region an alarm is created for billing. This alarm utilizes anomaly detection to detect anomalies in the Estimated Charges billing metric.

<img width="1346" alt="image" src="https://user-images.githubusercontent.com/97046295/197042518-a98d69df-8f53-4a4a-afb8-f424d91da56f.png">
