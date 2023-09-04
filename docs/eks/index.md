# Amazon EKS cluster metrics

This example demonstrates how to monitor your Amazon Elastic Kubernetes Service
(Amazon EKS) cluster with the Observability Accelerator's
[EKS monitoring module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring).

Monitoring Amazon Elastic Kubernetes Service (Amazon EKS) for metrics has two categories:
the control plane and the Amazon EKS nodes (with Kubernetes objects).
The Amazon EKS control plane consists of control plane nodes that run the Kubernetes software,
such as etcd and the Kubernetes API server. To read more on the components of an Amazon EKS cluster,
please read the [service documentation](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html).

The Amazon EKS infrastructure Terraform modules focuses on metrics collection to Amazon
Managed Service for Prometheus using the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html) for Amazon EKS. It deploys the [node exporter](https://github.com/prometheus/node_exporter) and [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) in your cluster.

It provides default dashboards to get a comprehensible visibility on your nodes,
namespaces, pods, and Kubelet operations health. Finally, you get curated Prometheus recording rules
and alerts to operate your cluster.

Additionally, you can optionally collect custom Prometheus metrics from your applications running
on your EKS cluster.

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.

## Setup

#### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/existing-cluster-with-base-and-infra
terraform init
```

#### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```

#### 3. Amazon EKS Cluster

To run this example, you need to provide your EKS cluster name. If you don't
have a cluster ready, visit [this example](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/new-eks-cluster/)
first to create a new one.

Specify your cluster name:

```bash
export TF_VAR_eks_cluster_id=xxx
```

#### 4. Amazon Managed Service for Prometheus workspace (optional)

By default, we create an Amazon Managed Service for Prometheus workspace for you.
However, if you have an existing workspace you want to reuse, edit and run:

```bash
export TF_VAR_managed_prometheus_workspace_id=ws-xxx
```

To create a workspace outside of Terraform's state, simply run:

```bash
aws amp create-workspace --alias observability-accelerator --query '.workspaceId' --output text
```

#### 5. Amazon Managed Grafana workspace

To visualize metrics collected, you need an Amazon Managed Grafana workspace. If you have
an existing workspace, create an environment variable as described below.
To create a new workspace, visit [our supporting example for Grafana](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/managed-grafana/)

!!! note
    For the URL `https://g-xyz.grafana-workspace.eu-central-1.amazonaws.com`, the workspace ID would be `g-xyz`

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
```

#### 6. Grafana API Key

Amazon Managed Grafana provides a control plane API for generating Grafana API keys.
As a security best practice, we will provide to Terraform a short lived API key to
run the `apply` or `destroy` command.

Ensure you have necessary IAM permissions (`CreateWorkspaceApiKey, DeleteWorkspaceApiKey`)

!!! note
    Starting version v2.5.x and above, we use Grafana Operator and External Secrets to
    manage Grafana contents. Your API Key will be stored securely on AWS SSM Parameter Store
    and the Grafana Operator will use it to sync dashboards, folders and data sources.
    Read more [here](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/).

```bash
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 7200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Visualization


#### 1. Grafana dashboards

Login to your Grafana workspace and navigate to the Dashboards panel. You should see a list of dashboards under the `Observability Accelerator Dashboards`
<img width="1540" alt="image" src="https://user-images.githubusercontent.com/10175027/190000716-29e16698-7c90-49d6-8c37-79ca1790e2cc.png">

Open a specific dashboard and you should be able to view its visualization
<img width="2056" alt="cluster headlines" src="https://user-images.githubusercontent.com/10175027/199110753-9bc7a9b7-1b45-4598-89d3-32980154080e.png">

With v2.5 and above, the dashboards are managed with a Grafana Operator running in your cluster.
From the cluster to view all dashboards as Kubernetes objects, run

```console
kubectl get grafanadashboards -A
NAMESPACE          NAME                                   AGE
grafana-operator   cluster-grafanadashboard               138m
grafana-operator   java-grafanadashboard                  143m
grafana-operator   kubelet-grafanadashboard               13h
grafana-operator   namespace-workloads-grafanadashboard   13h
grafana-operator   nginx-grafanadashboard                 134m
grafana-operator   node-exporter-grafanadashboard         13h
grafana-operator   nodes-grafanadashboard                 13h
grafana-operator   workloads-grafanadashboard             13h
```

You can inspect more details per dashboard using this command

```console
kubectl describe grafanadashboards cluster-grafanadashboard -n grafana-operator
```

Grafana Operator and Flux always work together to synchronize your dashboards with Git.
If you delete your dashboards by accident, they will be re-provisioned automatically.


#### 3. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you should find new rules deployed.

<img width="1629" alt="image" src="https://user-images.githubusercontent.com/10175027/189301297-4865e75d-2d71-434f-b5d0-9750b3533632.png">

!!! note
    To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)


## Custom Prometheus metrics collection

In addition to the cluster metrics, if you are interested in collecting Prometheus
metrics from your pods, you can use setup `custom metrics collection`.
This will instruct the ADOT collector to scrape your applications metrics based
on the configuration you provide. You can also exclude some of the metrics and save costs.

Using the example, you can edit `examples/existing-cluster-with-base-and-infra/main.tf`.
In the module `module "workloads_infra" {` add the following config (make sure the values matches your use case):

```hcl
enable_custom_metrics = true

custom_metrics_config = {
    custom_app_1 = {
        enableBasicAuth       = true
        path                  = "/metrics"
        basicAuthUsername     = "username"
        basicAuthPassword     = "password"
        ports                 = ".*:(8080)$"
        droppedSeriesPrefixes = "(unspecified.*)$"
    }
}
```

After applying Terraform, on Grafana, you can query Prometheus for your application metrics,
create alerts and build on your own dashboards. On the explorer section of Grafana, the
following query will give you the containers exposing metrics that matched the custom metrics
collection, grouped by cluster and node.

```promql
sum(up{job="custom-metrics"}) by (container_name, cluster, nodename)
```

<img width="2560" alt="Screenshot 2023-01-31 at 11 16 21" src="https://user-images.githubusercontent.com/10175027/215869004-e05f557d-c81a-41fb-a452-ede9f986cb27.png">
