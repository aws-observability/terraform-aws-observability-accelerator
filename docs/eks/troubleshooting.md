# Troubleshooting guide for Amazon EKS monitoring module

Depending on your setup, you might face a few errors. If you encounter an error
not listed here, please open an issue in the [issues section](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues).

This guide applies to the [eks-monitoring Terraform module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring).

## Cluster authentication issue

### Error message

```console
│ Error: The configmap "aws-auth" does not exist
```

or DNS resolution errors when Terraform tries to reach the EKS API server.

### Resolution

The environment where you run `terraform apply` must be authenticated against
your EKS cluster. Verify with:

```bash
kubectl get nodes
```

To configure kubectl for the correct cluster:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <aws-region>
```

## OTel Collector pod issues

### Collector pods not starting

Check the pod status and events:

```bash
kubectl get pods -n otel-collector
kubectl describe pod -n otel-collector -l app.kubernetes.io/name=opentelemetry-collector
```

Common causes:

- **IRSA role not configured** — verify the service account annotation:
  ```bash
  kubectl get sa -n otel-collector -o yaml
  ```
  The annotation `eks.amazonaws.com/role-arn` should be present.

- **Invalid OTel config** — check collector logs:
  ```bash
  kubectl logs -n otel-collector -l app.kubernetes.io/name=opentelemetry-collector
  ```

### Collector running but metrics not appearing

1. Verify the collector can reach scrape targets:
   ```bash
   kubectl exec -n otel-collector -it <pod-name> -- wget -qO- http://kube-state-metrics.kube-system.svc.cluster.local:8080/metrics | head -20
   ```

2. Check the collector's own metrics endpoint for pipeline health:
   ```bash
   kubectl port-forward -n otel-collector <pod-name> 8888:8888
   curl http://localhost:8888/metrics | grep otelcol_exporter
   ```

3. For AMP profiles, verify the workspace endpoint is reachable and the IRSA
   role has `AmazonPrometheusRemoteWriteAccess`.

4. For CloudWatch OTLP, verify the metrics endpoint URL is correct and the
   IRSA role has `cloudwatch:PutMetricData`.

## AMP Managed Collector (managed-metrics profile)

### Scraper creation fails

The AMP Managed Collector requires:

- At least 2 subnets in 2 distinct Availability Zones
- Security groups that allow outbound HTTPS to the EKS API server and AMP endpoint
- The EKS cluster's `aws-auth` ConfigMap must grant the scraper's IAM role access

Check the scraper status in the AMP console or via CLI:

```bash
aws amp list-scrapers --region <region>
```

### Scraper running but no metrics

1. Verify the scrape configuration is valid Prometheus YAML:
   ```bash
   terraform output -raw scrape_configuration | base64 -d | head -50
   ```

2. Check that kube-state-metrics and node-exporter pods are running:
   ```bash
   kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-state-metrics
   kubectl get pods -n prometheus-node-exporter
   ```

3. Verify the scraper's security groups allow traffic to the target pods.

## Grafana dashboard issues

### Dashboards not appearing

v3.0.0 provisions dashboards via the `grafana_dashboard` Terraform resource.
If dashboards are missing:

1. Verify `enable_dashboards = true` and `dashboard_delivery_method = "terraform"`
   (both are defaults).

2. Check that the Grafana provider is configured correctly:
   ```hcl
   provider "grafana" {
     url  = "https://g-xxx.grafana-workspace.us-west-2.amazonaws.com"
     auth = var.grafana_api_key
   }
   ```

3. Ensure the Grafana API key has `ADMIN` role and has not expired. Generate a
   new one:
   ```bash
   export TF_VAR_grafana_api_key=$(aws grafana create-workspace-api-key \
     --key-name "observability-accelerator-$(date +%s)" \
     --key-role ADMIN \
     --seconds-to-live 7200 \
     --workspace-id $TF_VAR_managed_grafana_workspace_id \
     --query key --output text)
   ```

4. Re-run `terraform apply` to re-provision dashboards.

### Dashboard JSON fetch errors

The default dashboards are fetched from GitHub URLs. If you are behind a
corporate proxy or firewall, the `data.http` data source may fail. In that
case, download the dashboard JSON files locally and pass them via
`dashboard_sources` with local file paths.

## Helm release issues

### Helm provider version mismatch

v3.0.0 requires Helm Terraform provider `>= 3.0.0`. If you see errors about
`set` blocks, upgrade the provider:

```bash
terraform init -upgrade
```

### Helm release stuck in pending state

```bash
helm list -n otel-collector
helm history -n otel-collector <release-name>
```

If a release is stuck, you may need to roll back:

```bash
helm rollback -n otel-collector <release-name> <revision>
```

## Upgrading from v2.x

If you encounter errors after upgrading from v2.x, see the
[Upgrading to v3.0.0](https://github.com/aws-observability/terraform-aws-observability-accelerator/blob/main/UPGRADING.md)
guide. The recommended migration path is `terraform destroy` of the v2.x module
followed by `terraform apply` with v3.0.0.
