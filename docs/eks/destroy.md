# Destroy resources

If you leave this stack running, you will continue to incur charges. To remove all resources
created by Terraform, [refresh your Grafana API key](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/#6-grafana-api-key) and run the command below.

!!! warning
    Be careful, this command will removing everything created by Terraform. If you wish
    to keep your Amazon Managed Grafana or Amazon Managed Service for Prometheus workspaces. Remove     them
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

> **Note:** To view all the features proposed by this module, visit the [module documentation](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/workloads/infra).
