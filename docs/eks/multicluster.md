# AWS EKS Multicluster Observability (single AWS Account)

This example shows how to use the [AWS Observability Accelerator](https://github.com/aws-observability/terraform-aws-observability-accelerator),
with more than one EKS cluster in a single account and visualize the collected
metrics from all the clusters in the dashboards of a common
`Amazon Managed Grafana` workspace.

## Prerequisites

#### 1. EKS clusters

Using the example [eks-cluster-with-vpc](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/new-eks-cluster/), create two EKS clusters with the names:

   1. `eks-cluster-1`
   2. `eks-cluster-2`

#### 2. Amazon Managed Service for Prometheus (AMP) workspace

We recommend that you create a new AMP workspace. To do that you can run the following command.

Ensure you have the following necessary IAM permissions

* `aps.CreateWorkspace`

```sh
export TF_VAR_managed_prometheus_workspace_id=$(aws amp create-workspace --alias observability-accelerator --query='workspaceId' --output text)
```

#### 3. Amazon Managed Grafana (AMG) workspace

To run this example you need an AMG workspace. If you have
an existing workspace, create an environment variable as described below.
To create a new workspace, visit our supporting example for managed Grafana.

!!! note
    For the URL `https://g-xyz.grafana-workspace.eu-central-1.amazonaws.com`, the workspace ID would be `g-xyz`

```sh
export TF_VAR_managed_grafana_workspace_id=g-xxx
```

#### 4. Grafana API Key

AMG provides a control plane API for generating Grafana API keys.
As a security best practice, we will provide to Terraform a short lived API key to
run the `apply` or `destroy` command.

Ensure you have the following necessary IAM permissions

* `grafana.CreateWorkspaceApiKey`
* `grafana.DeleteWorkspaceApiKey`

```sh
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 7200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Setup

#### 1. Download sources and initialize Terraform

```sh
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd terraform-aws-observability-accelerator/examples/eks-multicluster
terraform init
```

#### 2. Deploy

Verify by looking at the file `variables.tf` that there are two EKS clusters targeted for deployment by the names/ids:

1. `eks-cluster-1`
2. `eks-cluster-2`

The difference in deployment between these clusters is that Terraform, when setting up the EKS cluster behind variable `eks_cluster_1_id` for observability, also sets up:

* Dashboard folder and files in Amazon Managed Grafana
* Prometheus and Java, alerting and recording rules in Amazon Managed Service for Prometheus

!!! warning
    To override the defaults, create a `terraform.tfvars` and change the default values of the variables.

Run the following command to deploy

```sh
terraform apply --auto-approve
```

## Verifying Multicluster Observability

One you have successfully run the above setup, you should be able to see dashboards similar to the images shown below in `Amazon Managed Grafana` workspace.

Note how you are able to use the `cluster` dropdown to filter the dashboards to metrics collected from a specific EKS cluster.

<img width="2557" alt="eks-multicluster-1" src="https://user-images.githubusercontent.com/4762573/233949110-ce275d06-7ad8-494c-b527-d9c2a0fb6645.png">

<img width="2560" alt="eks-multicluster-2" src="https://user-images.githubusercontent.com/4762573/233949227-f401f81e-e0d6-4242-96ad-0bcd39ad4e2d.png">

## Cleanup

To clean up entirely, run the following command:

```sh
terraform destroy --auto-approve
```
