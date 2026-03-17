# Monitor Istio running on Amazon EKS

!!! warning "v3.0.0 breaking change"
    The `enable_istio` and `istio_config` variables have been removed in v3.0.0.
    Istio scrape targets are now added via `additional_scrape_jobs`. See the
    [Upgrading to v3.0.0](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/UPGRADING.md)
    guide.

## Setup with v3.0.0

Add Istio metrics endpoints as additional scrape jobs:

```hcl
module "eks_monitoring" {
  source = "github.com/aws-observability/terraform-aws-observability-accelerator//modules/eks-monitoring?ref=v3.0.0"

  providers = { grafana = grafana }

  collector_profile     = "self-managed-amp"  # or "cloudwatch-otlp"
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_provider_arn = var.eks_oidc_provider_arn

  additional_scrape_jobs = [
    {
      job_name        = "istiod"
      scrape_interval = "30s"
      static_configs = [
        { targets = ["istiod.istio-system.svc.cluster.local:15014"] }
      ]
    },
    {
      job_name = "envoy-stats"
      metrics_path = "/stats/prometheus"
      kubernetes_sd_configs = [
        { role = "pod" }
      ]
      relabel_configs = [
        {
          source_labels = ["__meta_kubernetes_pod_container_port_name"]
          action        = "keep"
          regex         = ".*-envoy-prom"
        }
      ]
    }
  ]
}
```

## Custom dashboards

To add Istio Grafana dashboards, include them in `dashboard_sources`:

```hcl
module "eks_monitoring" {
  # ...
  dashboard_sources = {
    istio-mesh      = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/istio/istio-mesh-dashboard.json"
    istio-service   = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/istio/istio-service-dashboard.json"
    istio-workload  = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/istio/istio-workload-dashboard.json"
    istio-cp        = "https://raw.githubusercontent.com/aws-observability/aws-observability-accelerator/v0.3.2/artifacts/grafana-dashboards/eks/istio/istio-control-plane-dashboard.json"
  }
}
```

## Prerequisites

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [istioctl](https://istio.io/latest/docs/setup/getting-started/#download)

## Deploy the Bookinfo sample application

Follow Istio's [Getting Started](https://istio.io/latest/docs/setup/getting-started/)
guide to install Istio, then deploy the Bookinfo sample:

```bash
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
istioctl analyze
```

Generate traffic:

```bash
GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')
for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done
```

Open your Amazon Managed Grafana workspace and navigate to the Istio dashboards.

## Destroy

```bash
kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
terraform destroy
```
