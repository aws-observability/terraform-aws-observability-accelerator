# Monitor Nginx applications running on Amazon EKS

!!! note
    Since v2.x, NGINX based applications monitoring on EKS has been merged within
    the [eks-monitoring module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring)
    to allow visibility both on the cluster and the workloads, [#59](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues/59).

In addition to EKS infrastructure monitoring, the current example provides
curated Grafana dashboards, Prometheus alerting and recording rules with multiple
configuration options for NGINX based workloads on EKS.

## Setup

### 1. Add NGINX metrics, dashboards and alerts

From the [EKS cluster monitoring example's](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/) configuration,
simply enable the NGINX pattern's flag.

```hcl

module "eks_monitoring" {
   ...
   enable_nginx = true
}
```

You can further customize the NGINX pattern by providing `nginx_config` [options](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/modules/eks-monitoring/README.md#input_nginx_config).

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

!!! note
    To see the complete NGINX example, open the [example on the repository](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/examples/existing-cluster-nginx)

## Visualization

1. Grafana dashboards

Go to the Dashboards panel of your Grafana workspace. You will see a list of dashboards under the `Observability Accelerator Dashboards`

<img width="1208" alt="image" src="https://user-images.githubusercontent.com/97046295/190665211-60faef71-d83d-4d59-ac80-bf4309d8c082.png">

Open the NGINX dashboard and you will be able to view its visualization

<img width="1850" alt="image" src="https://user-images.githubusercontent.com/97046295/196226043-e49afeb9-7828-467f-9199-5707cdc69aa9.png">

2. Amazon Managed Service for Prometheus rules and alerts

Open the Amazon Managed Service for Prometheus console and view the details of your workspace. Under the `Rules management` tab, you will find new rules deployed.

<img width="1054" alt="image" src="https://user-images.githubusercontent.com/97046295/190665728-ae8bb709-ad93-4629-b845-85c158dd1925.png">

!!! note
    To setup your alert receiver, with Amazon SNS, follow [this documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alertmanager-receiver.html)

## Deploy an example application to visualize metrics

In this section we will deploy sample application and extract metrics using AWS OpenTelemetry collector

### 1. Add the helm incubator repo:

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

### 2. Enter the following command to create a new namespace:

```sh
kubectl create namespace nginx-ingress-sample
```

### 3. Enter the following commands to install NGINX:

```sh
helm install my-nginx ingress-nginx/ingress-nginx \
--namespace nginx-ingress-sample \
--set controller.metrics.enabled=true \
--set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
--set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"
```

### 4. Set an EXTERNAL-IP variable to the value of the EXTERNAL-IP column in the row of the NGINX ingress controller.

```sh
EXTERNAL_IP=your-nginx-controller-external-ip
```

### 5. Start some sample NGINX traffic by entering the following command.

```sh
SAMPLE_TRAFFIC_NAMESPACE=nginx-sample-traffic
curl https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/main/examples/existing-cluster-nginx/sample_traffic/nginx-traffic-sample.yaml |
sed "s/{{external_ip}}/$EXTERNAL_IP/g" |
sed "s/{{namespace}}/$SAMPLE_TRAFFIC_NAMESPACE/g" |
kubectl apply -f -
```

### 6. Verify if the application is running

```sh
kubectl get pods -n nginx-ingress-sample
```

### 7. Visualize the Application's dashboard

Log back into your Managed Grafana Workspace and navigate to the dashboard side panel, click on `Observability Accelerator Dashboards` Folder and open the `NGINX` Dashboard.
