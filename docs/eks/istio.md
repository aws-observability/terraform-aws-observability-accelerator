# Monitor Istio running on Amazon EKS


In addition to EKS infrastructure monitoring, the current example provides
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options for Istio based workloads on EKS.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Setup

### 1. Add Istio metrics, dashboards and alerts

From the [EKS cluster monitoring example's](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/) configuration,
simply enable the Istio pattern's flag.

```hcl

module "eks_monitoring" {
   ...
   enable_istio = true
}
```

You can further customize the Istio pattern by providing `istio_config` [options](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/modules/eks-monitoring/README.md#input_istio_config).

### 2. Grafana API key

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

## Visualization

### 1. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You will see a list of Istio dashboards under the `Observability Accelerator Dashboards`

<img width="1208" alt="image" src="https://user-images.githubusercontent.com/47993564/236841811-fdd5a07c-6e5e-4654-a735-80f92f5bee56.jpeg">

Open one of the Istio dasbhoards and you will be able to view its visualization

<img width="1850" alt="image" src="https://user-images.githubusercontent.com/47993564/236842708-72225322-4f97-44cc-aac0-40a3356e50c6.jpeg">

### 2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you will find new rules deployed.

<img width="1054" alt="image" src="https://user-images.githubusercontent.com/47993564/236844084-80c754e3-4fe1-45bb-8361-181432675469.jpeg">

!!! note
    To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)

## Deploy an example application to visualize metrics

In this section we will deploy a sample application and extract metrics using the AWS OpenTelemetry collector

### 1. Deploy the Bookinfo Application

1. Using the AWS CLI, configure kubectl so you can connect to your EKS cluster. Update for your region and EKS cluster name
```sh
aws eks update-kubeconfig --region us-east-1 --name eks-blueprint
```
2. Label the default namespace for automatic Istio sidecar injection
```sh
kubectl label namespace default istio-injection=enabled
```
3. Navigate to the Istio folder location
4. Deploy the Bookinfo sample application
```sh
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```
5. Connect the Bookinfo application with the Istio gateway
```sh
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```
6. Validate that there are no issues with the Istio configuration
```sh
istioctl analyze
```
7. Get the DNS name of the load balancer for the Istio gateway
```sh
GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```
Additional details can be found on Istio's [Getting Started](https://istio.io/latest/docs/setup/getting-started/) documentation

### 2. Generate traffic for the Istio Bookinfo sample application

For the Bookinfo sample application, visit `http://$GATEWAY_URL/productpage` in your web browser. To see trace data, you must send requests to your service. The number of requests depends on Istio’s sampling rate and can be configured using the Telemetry API. With the default sampling rate of 1%, you need to send at least 100 requests before the first trace is visible. To send a 100 requests to the productpage service, use the following command:
```sh
$ for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done
```

### 3. Explore the Istio dashboards

Log back into your Amazon Managed Grafana workspace and navigate to the dashboard side panel. Click on the `Observability Accelerator Dashboards` folder and open the `Istio Service` Dashboard. Use the Service dropdown menu to select the `reviews.default.svc.cluster.local` service. This gives details about metrics for the service, client workloads (workloads that are calling this service), and service workloads (workloads that are providing this service).

Explore the Istio Control Plane, Mesh, and Performance dashboards as well.
