# Monitor Java/JMX applications running on Amazon EKS

The current example deploys the [AWS Distro for OpenTelemetry Operator](https://docs.aws.amazon.com/eks/latest/userguide/opentelemetry.html) for Amazon EKS with its requirements and make use of existing
Amazon Managed Service for Prometheus and Amazon Managed Grafana workspaces.

It is based on the `java module`, one of our [workloads modules](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/workloads/java)
to provide to an existing EKS cluster with an OpenTelemetry collector,
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options on the cluster infrastructure.

## Prerequisites

Make sure to complete the [prerequisites section](/terraform-aws-observability-accelerator/concepts/#prerequisites)
before proceeding.

## Setup

This example uses a local terraform state. If you need states to be saved remotely,
on Amazon S3 for example, visit the [terraform remote states](https://www.terraform.io/language/state/remote) documentation.

Here we use terraform supported environment variables, but you can also edit the `terraform.tfvars` file directly and deploy
with `terraform apply -var-file=terraform.tfvars`. Terraform tfvars file can be useful if
you need to track changes as part of a Git repository or CI/CD pipeline.

### 1. Download sources and initialize Terraform

```bash
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd examples/existing-cluster-java
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

To create a new one, within this example's Terraform state (sharing the same lifecycle with all the other resources):

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

Open your Grafana workspace and under Configuration -> Data sources, you will see `aws-observability-accelerator`. Open and click `Save & test`. You will then see a notification confirming that the Amazon Managed Service for Prometheus workspace is ready to be used on Grafana.

2. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. There will be a folder called `Observability Accelerator Dashboards`

<img width="832" alt="image" src="https://user-images.githubusercontent.com/97046295/194903648-57c55d30-6f90-4b03-9eb6-577aaba7dc22.png">

Open the "Java/JMX" dashboard to view its visualization


![image](https://user-images.githubusercontent.com/10175027/195903211-c47a5746-daa7-41f2-a6ea-bfe13f630c63.png)


2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you will find new rules deployed.

<img width="1314" alt="image" src="https://user-images.githubusercontent.com/97046295/194904104-09a28577-d149-478e-b0a1-dc21cb7effc1.png">


To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)


## Deploy an Example Java Application

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