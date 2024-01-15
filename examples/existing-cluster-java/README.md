# Monitor Java applications running on Amazon EKS

This example demonstrates how to use the AWS Observability Accelerator Terraform
modules to monitor EKS infrastructure and Java based workloads.
The current example deploys the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html)
for Amazon EKS with its requirements and make use of an existing Amazon Managed Grafana workspace.
It creates a new Amazon Managed Service for Prometheus workspace unless provided with an existing one to reuse.

Since v2.x releases, it uses the `EKS monitoring` [module](../../modules/eks-monitoring/)
to provide an existing EKS cluster with an OpenTelemetry collector,
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options on the cluster infrastructure.
You will gain both visibility on the cluster and Java based applications.


## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
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
cd examples/existing-cluster-java
terraform init
```

3. Amazon EKS Cluster

To run this example, you need to provide your EKS cluster name.
If you don't have a cluster ready, visit [this example](../eks-cluster-with-vpc)
first to create a new one.

Add your cluster name for `eks_cluster_id="..."` to the `terraform.tfvars` or use an environment variable `export TF_VAR_eks_cluster_id=xxx`.

4. Amazon Managed Grafana workspace

To run this example you need an Amazon Managed Grafana workspace. If you have
an existing workspace, create an environment variable
`export TF_VAR_managed_grafana_workspace_id=g-xxx`.

To create a new one, visit [this example](../managed-grafana-workspace).

> In the URL `https://g-xyz.grafana-workspace.eu-central-1.amazonaws.com`, the workspace ID would be `g-xyz`

5. <a name="apikey"></a> Grafana API Key

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

## Additional configuration

For the purpose of the example, we have provided default values for some of the variables.

1. AWS Region

Specify the AWS Region where the resources will be deployed. Edit the `terraform.tfvars` file and modify `aws_region="..."`. You can also use environement variables `export TF_VAR_aws_region=xxx`.


2. Amazon Managed Service for Prometheus workspace

If you have an existing workspace, add `managed_prometheus_workspace_id=ws-xxx`
or use an environment variable `export TF_VAR_managed_prometheus_workspace_id=ws-xxx`.

## Visualization

1. Prometheus datasource on Grafana

Make sure to open the link in the output. After a successful deployment, this will open
the Prometheus datasource configuration on Grafana.
Click `Save & test` and you should see a notification confirming that the Amazon Managed Service for Prometheus workspace is ready to be used on Grafana.

```bash
terraform output grafana_prometheus_datasource_test
```

2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. There will be a folder called `Observability Accelerator Dashboards`

<img width="832" alt="image" src="https://user-images.githubusercontent.com/97046295/194903648-57c55d30-6f90-4b03-9eb6-577aaba7dc22.png">

Open the "Java/JMX" dashboard to view its visualization

<img width="2560" alt="Grafana Java dashboard" src="https://user-images.githubusercontent.com/10175027/217821001-2119c81f-94bd-4811-8bbb-caaf1ae5a77a.png">

2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you will find new rules deployed.

<img width="1314" alt="image" src="https://user-images.githubusercontent.com/97046295/194904104-09a28577-d149-478e-b0a1-dc21cb7effc1.png">

To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)


## Deploy an example Java application

In this section we will reuse an example from the AWS OpenTelemetry collector [repository](https://github.com/aws-observability/aws-otel-collector/blob/main/docs/developers/container-insights-eks-jmx.md). For convenience, the steps can be found below.

1. Clone [this repository](https://github.com/aws-observability/aws-otel-test-framework) and navigate to the `sample-apps/jmx/` directory.

2. Authenticate to Amazon ECR

```sh
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION={region}
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

3. Create an Amazon ECR repository

```sh
aws ecr create-repository --repository-name prometheus-sample-tomcat-jmx \
 --image-scanning-configuration scanOnPush=true \
 --region $AWS_REGION
```

4. Build Docker image and push to ECR.

```sh
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest
```

5. Install sample application

```sh
export SAMPLE_TRAFFIC_NAMESPACE=javajmx-sample
curl https://raw.githubusercontent.com/aws-observability/aws-otel-test-framework/terraform/sample-apps/jmx/examples/prometheus-metrics-sample.yaml > metrics-sample.yaml
sed -i "s/{{aws_account_id}}/$AWS_ACCOUNT_ID/g" metrics-sample.yaml
sed -i "s/{{region}}/$AWS_REGION/g" metrics-sample.yaml
sed -i "s/{{namespace}}/$SAMPLE_TRAFFIC_NAMESPACE/g" metrics-sample.yaml
kubectl apply -f metrics-sample.yaml
```

Verify that the sample application is running:

```sh
kubectl get pods -n $SAMPLE_TRAFFIC_NAMESPACE

NAME                              READY   STATUS              RESTARTS   AGE
tomcat-bad-traffic-generator      1/1     Running             0          11s
tomcat-example-7958666589-2q755   0/1     ContainerCreating   0          11s
tomcat-traffic-generator          1/1     Running             0          11s
```

## Destroy resources

If you leave this stack running, you will continue to incur charges. To remove all resources
created by Terraform, [refresh your Grafana API key](#apikey) and run:

```sh
terraform destroy -var-file=terraform.tfvars
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_monitoring"></a> [eks\_monitoring](#module\_eks\_monitoring) | ../../modules/eks-monitoring | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/grafana_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_enable_dashboards"></a> [enable\_dashboards](#input\_enable\_dashboards) | Enables or disables curated dashboards | `bool` | `true` | no |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | API key for external-secrets to create secrets for grafana-operator | `string` | n/a | yes |
| <a name="input_managed_grafana_workspace_id"></a> [managed\_grafana\_workspace\_id](#input\_managed\_grafana\_workspace\_id) | Amazon Managed Grafana Workspace ID | `string` | n/a | yes |
| <a name="input_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#input\_managed\_prometheus\_workspace\_id) | Amazon Managed Service for Prometheus Workspace ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS Cluster Id |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS Cluster version |
| <a name="output_managed_prometheus_workspace_endpoint"></a> [managed\_prometheus\_workspace\_endpoint](#output\_managed\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus workspace endpoint |
| <a name="output_managed_prometheus_workspace_id"></a> [managed\_prometheus\_workspace\_id](#output\_managed\_prometheus\_workspace\_id) | Amazon Managed Prometheus workspace ID |
| <a name="output_managed_prometheus_workspace_region"></a> [managed\_prometheus\_workspace\_region](#output\_managed\_prometheus\_workspace\_region) | AWS Region |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
