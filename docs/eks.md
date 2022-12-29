# Amazon EKS cluster monitoring

This example demonstrates how to monitor your Amazon Elastic Kubernetes Service
(Amazon EKS) cluster with the Observability Accelerator's EKS
[infrastructure module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/workloads/infra).

Monitoring Amazon Elastic Kubernetes Service (Amazon EKS) has two categories:
the control plane and the Amazon EKS nodes (with Kubernetes objects).
The Amazon EKS control plane consists of control plane nodes that run the Kubernetes software,
such as etcd and the Kubernetes API server. To read more on the components of an Amazon EKS cluster,
please read the [service documentation](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html).

The Amazon EKS infrastructure Terraform modules focuses on metrics collection to Amazon
Managed Service for Prometheus using the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html) for Amazon EKS.
Additionally, it provides default dashboards to get a comprehensible visibility on the nodes,
namespaces, pods, and kubelet operations health. Finally, you get curated Prometheus recording rules
and alerts to operate your cluster.

## Prerequisites

Make sure to complete the [prerequisites section](/terraform-aws-observability-accelerator/concepts/#prerequisites)
before proceeding.

## Setup

### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/existing-cluster-with-base-and-infra
terraform init
```

### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```

### 3. Amazon EKS Cluster

To run this example, you need to provide your EKS cluster name. If you don't
have a cluster ready, visit [this example](/terraform-aws-observability-accelerator/helpers/new-eks-cluster.md)
first to create a new one.

Specify your cluster name:

```bash
export TF_VAR_eks_cluster_id=xxx
```

### 4. Amazon Managed Service for Prometheus workspace (optional)

By default, we create an Amazon Managed Service for Prometheus workspace for you.
However, if you have an existing workspace you want to reuse, edit and run:

```bash
export TF_VAR_managed_prometheus_workspace_id=ws-xxx
```

To create a workspace outside of Terraform's state, simply run:

```bash
aws amp create-workspace --alias observability-accelerator --query '.workspaceId' --output text
```

### 5. Amazon Managed Grafana workspace

To run this example you need an Amazon Managed Grafana workspace. If you have an existing workspace, edit and run:

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
```

To create a new one, within this example's Terraform state (sharing the same lifecycle with all the
other resources created by Terraform):

- Edit main.tf and set `enable_managed_grafana = true`
- Run

```bash
terraform init
terraform apply -target "module.eks_observability_accelerator.module.managed_grafana[0].aws_grafana_workspace.this[0]"
export TF_VAR_managed_grafana_workspace_id=$(terraform output --raw managed_grafana_workspace_id)
```

### 6. Grafana API Key

Amazon Managed Grafana provides a control plane API for generating Grafana API keys.
As a security best practice, we will provide to Terraform a short lived API key to
run the `apply` or `destroy` command.

Ensure you have necessary IAM permissions (`CreateWorkspaceApiKey, DeleteWorkspaceApiKey`)

```bash
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 1200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Visualization

1. Prometheus datasource on Grafana

Open your Grafana workspace and under Configuration -> Data sources, you should see `aws-observability-accelerator`. Open and click `Save & test`. You should see a notification confirming that the Amazon Managed Service for Prometheus workspace is ready to be used on Grafana.

2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You should see a list of dashboards under the `Observability Accelerator Dashboards`

<img width="1540" alt="image" src="https://user-images.githubusercontent.com/10175027/190000716-29e16698-7c90-49d6-8c37-79ca1790e2cc.png">

Open a specific dashboard and you should be able to view its visualization

<img width="2056" alt="cluster headlines" src="https://user-images.githubusercontent.com/10175027/199110753-9bc7a9b7-1b45-4598-89d3-32980154080e.png">

2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you should find new rules deployed.

<img width="1629" alt="image" src="https://user-images.githubusercontent.com/10175027/189301297-4865e75d-2d71-434f-b5d0-9750b3533632.png">


To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)


## Destroy resources

If you leave this stack running, you will continue to incur charges. To remove all resources
created by Terraform, [refresh your Grafana API key](#6-grafana-api-key) and run the command below.

Be careful, this command will removing everything created by Terraform. If you wish
to keep your Amazon Managed Grafana or Amazon Managed Service for Prometheus workspaces. Remove them
from your terraform state before running the destroy command.

```bash
terraform destroy
```

To remove resources from your Terraform state, run

```bash
# grafana workspace
terraform state rm "module.eks_observability_accelerator.module.managed_grafana[0].aws_grafana_workspace.this[0]"

# prometheus workspace
terraform state rm "module.eks_observability_accelerator.aws_prometheus_workspace.this[0]"
```


> **Note:** To view all the features proposed by this module, visit the [module documentation](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/workloads/infra).