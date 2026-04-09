#--------------------------------------------------------------
# CloudWatch Agent EKS Add-on — Container Insights with OTel
#
# Add-on v1.5.0+ automatically creates a service-linked role.
# No Pod Identity or IRSA configuration needed.
#--------------------------------------------------------------

resource "aws_eks_addon" "cloudwatch_agent" {
  cluster_name                = var.eks_cluster_id
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    agent = {
      config = {
        logs = {
          metrics_collected = {
            kubernetes = {
              enhanced_container_insights = true
            }
          }
        }
      }
    }
    containerLogs = {
      enabled = true
    }
  })
}
