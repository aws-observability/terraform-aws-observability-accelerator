#--------------------------------------------------------------
# AMP Workspace
#--------------------------------------------------------------

resource "aws_prometheus_workspace" "this" {
  count = var.create_amp_workspace ? 1 : 0

  alias = var.amp_workspace_alias
  tags  = var.tags
}

data "aws_prometheus_workspace" "existing" {
  count = !var.create_amp_workspace && var.managed_prometheus_workspace_id != null ? 1 : 0

  workspace_id = var.managed_prometheus_workspace_id
}
