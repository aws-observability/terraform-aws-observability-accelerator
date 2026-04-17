#--------------------------------------------------------------
# CloudWatch Agent EKS Add-on (cloudwatch-otlp profile)
#
# Deploys the Amazon CloudWatch Observability add-on which includes:
#   - CloudWatch Agent DaemonSet (metrics + Container Insights)
#   - CloudWatch Agent Operator
#   - Fluent Bit DaemonSet (container logs)
#   - kube-state-metrics
#   - node-exporter
#
# Add-on v1.5.0+ enables Container Insights v2 (OTLP) by default.
# IAM via EKS Pod Identity (requires eks-pod-identity-agent addon).
#--------------------------------------------------------------

resource "aws_eks_addon" "cloudwatch_agent" {
  count = local.is_cloudwatch_otlp ? 1 : 0

  cluster_name                = var.eks_cluster_id
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = var.cw_agent_addon_version != "" ? var.cw_agent_addon_version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = aws_iam_role.cw_agent[0].arn
    service_account = "cloudwatch-agent"
  }

  configuration_values = jsonencode(merge(
    {
      containerLogs = {
        enabled = var.cw_agent_enable_container_logs
      }
    },
    var.cw_agent_enable_application_signals ? {
      manager = {
        applicationSignals = {
          autoMonitor = {
            monitorAllServices = true
          }
        }
      }
    } : {},
  ))

  tags = var.tags
}

#--------------------------------------------------------------
# Pod Identity IAM Role for CW Agent
#--------------------------------------------------------------

resource "aws_iam_role" "cw_agent" {
  count = local.is_cloudwatch_otlp ? 1 : 0

  name = "${var.eks_cluster_id}-cw-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cw_agent_server" {
  count      = local.is_cloudwatch_otlp ? 1 : 0
  role       = aws_iam_role.cw_agent[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#--------------------------------------------------------------
# CWA OTLP Gateway (Deployment mode)
#
# A lightweight CWA Deployment that accepts OTLP (gRPC/HTTP)
# from application workloads and forwards to CloudWatch.
# Deployed only when enable_otlp_gateway = true.
#
# Uses the AmazonCloudWatchAgent CRD managed by the operator
# that the add-on already installed.
#
# NOTE: We use terraform_data + local-exec instead of
# kubernetes_manifest because the latter validates the CRD at
# plan time, before the EKS addon has installed it — breaking
# single-apply workflows.
#
# Apps send telemetry to:
#   grpc: cwa-otlp-gateway.<namespace>:4315
#   http: cwa-otlp-gateway.<namespace>:4316
#--------------------------------------------------------------

resource "terraform_data" "cwa_otlp_gateway" {
  count = local.needs_otlp_gateway ? 1 : 0

  input = {
    manifest   = local.otlp_gateway_manifest_yaml
    cluster_id = var.eks_cluster_id
    region     = local.region
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      KUBECONFIG=$(mktemp)
      trap 'rm -f "$KUBECONFIG"' EXIT
      aws eks update-kubeconfig --name '${self.input.cluster_id}' --region '${self.input.region}' --kubeconfig "$KUBECONFIG" >/dev/null
      cat <<'EOF' | kubectl --kubeconfig "$KUBECONFIG" apply -f -
      ${self.input.manifest}
      EOF
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      KUBECONFIG=$(mktemp)
      trap 'rm -f "$KUBECONFIG"' EXIT
      aws eks update-kubeconfig --name '${self.output.cluster_id}' --region '${self.output.region}' --kubeconfig "$KUBECONFIG" >/dev/null
      cat <<'EOF' | kubectl --kubeconfig "$KUBECONFIG" delete -f - --ignore-not-found
      ${self.output.manifest}
      EOF
    EOT
  }

  depends_on = [aws_eks_addon.cloudwatch_agent]
}
