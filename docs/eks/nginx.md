# Monitor NGINX applications running on Amazon EKS

!!! warning "v3.0.0 breaking change"
    The `enable_nginx` and `nginx_config` variables have been removed in v3.0.0.
    NGINX scrape targets are now added via `additional_scrape_jobs`. See the
    [Upgrading to v3.0.0](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/UPGRADING.md)
    guide.

## Setup with v3.0.0

Add your NGINX metrics endpoint as an additional scrape job:

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile     = "self-managed-amp"  # or "cloudwatch-otlp"
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  additional_scrape_jobs = [
    {
      job_name        = "nginx"
      scrape_interval = "30s"
      static_configs = [
        { targets = ["my-nginx.nginx-ingress-sample.svc.cluster.local:10254"] }
      ]
    }
  ]
}
```

## Custom dashboards

To add an NGINX Grafana dashboard, include it in `dashboard_sources`:

```hcl
module "eks_monitoring" {
  # ...
  dashboard_sources = {
    nginx = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/nginx/nginx.json"
  }
}
```

## Deploy a sample NGINX application

### 1. Install NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
kubectl create namespace nginx-ingress-sample
helm install my-nginx ingress-nginx/ingress-nginx \
  --namespace nginx-ingress-sample \
  --set controller.metrics.enabled=true \
  --set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
  --set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"
```

### 2. Generate sample traffic

```bash
EXTERNAL_IP=$(kubectl get svc my-nginx-ingress-nginx-controller -n nginx-ingress-sample -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
SAMPLE_TRAFFIC_NAMESPACE=nginx-sample-traffic
curl https://raw.githubusercontent.com/aws-observability/terraform-aws-observability-accelerator/main/examples/eks-amp-otel-nginx/sample_traffic/nginx-traffic-sample.yaml |
sed "s/{{external_ip}}/$EXTERNAL_IP/g" |
sed "s/{{namespace}}/$SAMPLE_TRAFFIC_NAMESPACE/g" |
kubectl apply -f -
```

### 3. Verify and visualize

```bash
kubectl get pods -n nginx-ingress-sample
```

Open your Managed Grafana workspace and navigate to the NGINX dashboard.
