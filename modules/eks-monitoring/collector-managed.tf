#--------------------------------------------------------------
# AMP Managed Collector (managed-metrics profile)
#--------------------------------------------------------------

resource "aws_prometheus_scraper" "this" {
  count = local.is_managed_metrics ? 1 : 0

  alias = "${var.eks_cluster_id}-scraper"

  source {
    eks {
      cluster_arn        = data.aws_eks_cluster.this.arn
      security_group_ids = var.scraper_security_group_ids
      subnet_ids         = var.scraper_subnet_ids
    }
  }

  destination {
    amp {
      workspace_arn = local.amp_workspace_arn
    }
  }

  scrape_configuration = local.scrape_configuration_base64

  tags = var.tags
}
