# Monitor Java/JMX applications running on Amazon EKS

!!! note
    Since v2.x, Java based applications monitoring on EKS has been merged within
    the [eks-monitoring module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring)
    to allow visibility both on the cluster and the workloads, [#59](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues/59).

In addition to EKS infrastructure monitoring, the current example provides
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options for Java based workloads on EKS.

## Setup

#### 1. Add Java metrics, dashboards and alerts

From the [previous example's](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/) configuration,
simply enable the Java pattern's flag.

```hcl

module "eks_monitoring" {
   ...
   enable_java = true
}
```

You can further customize the Java pattern by providing `java_config` [options](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/modules/eks-monitoring/README.md#input_java_config).

#### 2. Grafana API key

Make sure to refresh your temporary Grafana API key

```bash
export TF_VAR_managed_grafana_workspace_id=g-xxx
export TF_VAR_grafana_api_key=`aws grafana create-workspace-api-key --key-name "observability-accelerator-$(date +%s)" --key-role ADMIN --seconds-to-live 1200 --workspace-id $TF_VAR_managed_grafana_workspace_id --query key --output text`
```

## Deploy

Simply run this command to deploy.

```bash
terraform apply
```

!!! note
    To see the complete Java example, open the [example on the repository](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/examples/existing-cluster-java)

## Visualization

#### 1. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. There will be a folder called `Observability Accelerator Dashboards`

<img width="832" alt="image" src="https://user-images.githubusercontent.com/97046295/194903648-57c55d30-6f90-4b03-9eb6-577aaba7dc22.png">

Open the "Java/JMX" dashboard to view its visualization

<img width="2560" alt="Grafana Java dashboard" src="https://user-images.githubusercontent.com/10175027/217821001-2119c81f-94bd-4811-8bbb-caaf1ae5a77a.png">

#### 2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you will find new rules deployed.

<img width="1314" alt="image" src="https://user-images.githubusercontent.com/97046295/194904104-09a28577-d149-478e-b0a1-dc21cb7effc1.png">

!!! note
    To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)


## Deploy an example Java application

In this section we will reuse an example from the AWS OpenTelemetry collector [repository](https://github.com/aws-observability/aws-otel-collector/blob/main/docs/developers/container-insights-eks-jmx.md). For convenience, the steps can be found below.

#### 1. Clone repository

```sh
git clone https://github.com/aws-observability/aws-otel-test-framework)
cd sample-apps/jmx/
```

#### 2. Authenticate to Amazon ECR

```sh
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION={region}
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

#### 3. Create an Amazon ECR repository

```sh
aws ecr create-repository --repository-name prometheus-sample-tomcat-jmx \
 --image-scanning-configuration scanOnPush=true \
 --region $AWS_REGION
```

#### 4. Build Docker image and push to ECR.

```sh
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/prometheus-sample-tomcat-jmx:latest
```

#### 5. Install sample application

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
