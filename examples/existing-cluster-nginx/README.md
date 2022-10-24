# Existing Cluster with the AWS Observability accelerator base module and Nginx monitoring


This example demonstrates how to use the AWS Observability Accelerator Terraform
modules with Nginx monitoring enabled.
The current example deploys the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html) for Amazon EKS with its requirements and make use of existing
Amazon Managed Service for Prometheus and Amazon Managed Grafana workspaces.

It is based on the `nginx module`, one of our [workload modules](../../modules/workloads/)
to provide an existing EKS cluster with an OpenTelemetry collector,
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options on the cluster infrastructure.


## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)


## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation

1. Clone the repo using the command below

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
```

2. Initialize terraform

```console
cd examples/existing-cluster-nginx
terraform init
```

3. AWS Region

Specify the AWS Region where the resources will be deployed. Edit the `terraform.tfvars` file and modify `aws_region="..."`. You can also use environement variables `export TF_VAR_aws_region=xxx`.

4. Amazon EKS Cluster

To run this example, you need to provide your EKS cluster name.
If you don't have a cluster ready, visit [this example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/eks-cluster-with-new-vpc)
first to create a new one.

Add your cluster name for `eks_cluster_id="..."` to the `terraform.tfvars` or use an environment variable `export TF_VAR_eks_cluster_id=xxx`.

5. Amazon Managed Service for Prometheus workspace (optional)

If you have an existing workspace, add `managed_prometheus_workspace_id=ws-xxx`
or use an environment variable `export TF_VAR_managed_prometheus_workspace_id=ws-xxx`.

If you don't specify anything a new workspace will be created for you.

6. Amazon Managed Grafana workspace

If you have an existing workspace, add `managed_grafana_workspace_id=g-xxx`
or use an environment variable `export TF_VAR_managed_grafana_workspace_id=g-xxx`.

7. Grafana API Key

- Give admin access to the SSO user you set up when creating the Amazon Managed Grafana Workspace:
- In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click **All workspaces**, then click on the workspace name you are using for this example.
- Under **Authentication** within **AWS Single Sign-On (SSO)**, click **Configure users and user groups**
- Check the box next to the SSO user you created and click **Make admin**
- From the workspace in the AWS console, click on the `Grafana workspace URL` to open the workspace
- If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the **API keys** tab.
- Click **Add API key**, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `terraform.tfvars` under the `grafana_api_key` variable (`grafana_api_key="xxx"`) or set as an environment variable on your CLI (`export TF_VAR_grafana_api_key="xxx"`)


## Deploy

```sh
terraform apply -var-file=terraform.tfvars
```

or if you had setup environment variables, run

```sh
terraform apply
```

## Visualization

1. Prometheus datasource on Grafana

Open your Grafana workspace and under Configuration -> Data sources, you should see `aws-observability-accelerator`. Open and click `Save & test`. You should see a notification confirming that the Amazon Managed Service for Prometheus workspace is ready to be used on Grafana.

2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You should see a list of dashboards under the `Observability Accelerator Dashboards`

<img width="1208" alt="image" src="https://user-images.githubusercontent.com/97046295/190665211-60faef71-d83d-4d59-ac80-bf4309d8c082.png">

Open the NGINX dashboard and you should be able to view its visualization

<img width="1850" alt="image" src="https://user-images.githubusercontent.com/97046295/196226043-e49afeb9-7828-467f-9199-5707cdc69aa9.png">

2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you should find new rules deployed.

<img width="1054" alt="image" src="https://user-images.githubusercontent.com/97046295/190665728-ae8bb709-ad93-4629-b845-85c158dd1925.png">


To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)

## Deploy an Example Application to Visualize

In this section we will deploy sample application and extract metrics using AWS OpenTelemetry collector

1. Add the helm incubator repo:

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

2. Enter the following command to create a new namespace:

```sh
kubectl create namespace nginx-ingress-sample
```

3. Enter the following commands to install NGINX:

```sh
helm install my-nginx ingress-nginx/ingress-nginx \
--namespace nginx-ingress-sample \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"
```

4. Set an EXTERNAL-IP variable to the value of the EXTERNAL-IP column in the row of the NGINX ingress controller.

```sh
EXTERNAL_IP=your-nginx-controller-external-ip
```

5. Start some sample NGINX traffic by entering the following command.

```sh
SAMPLE_TRAFFIC_NAMESPACE=nginx-sample-traffic
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-deployment-manifest-templates/deployment-mode/service/cwagent-prometheus/sample_traffic/nginx-traffic/nginx-traffic-sample.yaml |
sed "s/{{external_ip}}/$EXTERNAL_IP/g" |
sed "s/{{namespace}}/$SAMPLE_TRAFFIC_NAMESPACE/g" |
kubectl apply -f -
```

4. Verify if the application is running

```sh
kubectl get pods -n nginx-ingress-sample
```

#### Visualize the Application's dashboard

Log back into your Managed Grafana Workspace and navigate to the dashboard side panel, click on `Observability Accelerator Dashboards` Folder and open the `NGINX` Dashboard.

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy
```

## Advanced configuration

1. Cross-region Amazon Managed Prometheus workspace

If your existing Amazon Managed Prometheus workspace is in another AWS Region,
add this `managed_prometheus_region=xxx` and `managed_prometheus_workspace_id=ws-xxx`.

2. Cross-region Amazon Managed Grafana workspace

If your existing Amazon Managed Prometheus workspace is in another AWS Region,
add this `managed_prometheus_region=xxx` and `managed_prometheus_workspace_id=ws-xxx`.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.25.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_observability_accelerator"></a> [eks\_observability\_accelerator](#module\_eks\_observability\_accelerator) | ../../ | n/a |
| <a name="module_workloads_nginx"></a> [workloads\_nginx](#module\_workloads\_nginx) | ../../modules/workloads/nginx | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | `""` | no |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | Amazon Managed Grafana (AMG) workspace ID | `string` | `""` | no |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Service for Prometheus (AMP) workspace ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS Region |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS Cluster version |
| <a name="output_grafana_dashboard_urls"></a> [grafana\_dashboard\_urls](#output\_grafana\_dashboard\_urls) | URLs for dashboards created |
| <a name="output_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#output\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus workspace endpoint |
| <a name="output_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#output\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus workspace ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
