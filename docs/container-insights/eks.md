# Setting Up Container Insights for your EKS Cluster

This example deploys CloudWatch Observability EKS add-on on an exisiting Amazon EKS cluster, which enables Container Insights enhanced observability for Amazon EKS and CloudWatch Application Signals by default.

1. Enables the CloudWatch Observability Add-on on EKS using the IAM service account role
2. Creates an IAM Service Linked role for enabling Application Signals

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.

## Setup

### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd terraform-aws-observability-accelerator/examples/eks-container-insights
terraform init
```

### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```
### 2. EKS Cluster Name

Specify the EKS Cluster Name where the resources will be deployed:

```bash
export TF_VAR_eks_cluster_id=xxx
```

### 3. Disable creation of `Cloudwatch Application Signals Service-linked Role`
If you already have Application Signals deployed in your AWS account, please set the value of this variable to `false`
```
variable "create_cloudwatch_application_signals_role" {
  type        = bool
  default     = true
  description = "Create a Cloudwatch Application Signals service-linked role"
}
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Enabling Application Signals (preview) for your services
CloudWatch Application Signals (preview) is currenlty supported for **Java** applications running on your Amazon EKS cluster.

Next, you have to update your Application to `Configure application metrics and trace sampling`. For this, you must add an annotation to a manifest YAML in your cluster. Adding this annotation auto-instruments the application to send metrics, traces, and logs to Application Signals. You have two options for the annotation:

1. **Annotate Workload** auto-instruments a single workload in the cluster.
    - Paste the below line into the PodTemplate section of the workload manifest.
    ```
    annotations: instrumentation.opentelemetry.io/inject-java: "true"
    ```
    - In your terminal, enter `kubectl apply -f your_deployment_yaml` to apply the change.

2. **Annotate Namespace** auto-instruments all workloads deployed in the selected namespace.
    - Paste the below line into the metadata section of the namespace manifest.
    ```
    annotations: instrumentation.opentelemetry.io/inject-java: "true"
    ```
    - In your terminal, enter `kubectl apply -f your_namespace_yaml` to apply the change.
    - In your terminal, enter a command to restart all pods in the namespace. An example command to restart deployment workloads is `kubectl rollout restart deployment -n namespace_name`

## Visualization of Container Insights data

After `terraform apply` is successful, open your Amazon CloudWatch console in the same region as your EKS cluster, then from the left hand side choose `Insights -> Container Insights`, there choose the `EKS` from the drop down and you will see the metrics shown on the dashboard:

<img width="1345" alt="image" src="https://github.com/ruchimo/terraform-aws-observability-accelerator/assets/106240341/31686b29-8ec2-46ff-a266-ebfa1de9768a">


## Visualization of CloudWatch Application Signals (preview) data

After enabling your Application to pass metrics and traces by following [the steps provided above](#enabling-application-signals-preview-for-your-services), open your Amazon CloudWatch console in the same region as your EKS cluster, then from the left hand side choose `Application Signals -> Services` and you will see the metrics shown on the sample dashboard below:

<img width="1321" alt="image" src="https://github.com/ruchimo/terraform-aws-observability-accelerator/assets/106240341/2fccf784-6560-45a9-8be0-4e843c9653f1">

<img width="1300" alt="image" src="https://github.com/ruchimo/terraform-aws-observability-accelerator/assets/106240341/69749d78-7c9a-4019-a023-f5412ab3b2de">

## Cleanup

To clean up your environment, destroy the Terraform example by running

```sh
terraform destroy
```
