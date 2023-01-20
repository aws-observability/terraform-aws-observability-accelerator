data "aws_ssoadmin_instances" "example" {}

resource "aws_identitystore_user" "example" {
  count = length(var.identitystore_admins_info)

  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  display_name      = "${var.identitystore_admins_info[count.index].first_name} ${var.identitystore_admins_info[count.index].last_name}"
  user_name         = var.identitystore_admins_info[count.index].email

  name {
    given_name  = var.identitystore_admins_info[count.index].first_name
    family_name = var.identitystore_admins_info[count.index].last_name
  }

  emails {
    value = var.identitystore_admins_info[count.index].email
    primary = true
  }

}


resource "aws_grafana_workspace" "workshop" {
  name                     = "eks-observability-workshop-workspace"
  description              = "EKS Observability Workshop's Grafana Workspace"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.assume.arn
  data_sources             = ["PROMETHEUS"]
}

resource "aws_iam_role" "assume" {
  name = "eks-observability-accelerator-grafana-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_grafana_workspace_api_key" "key" {
  key_name        = "admin"
  key_role        = "ADMIN"
  seconds_to_live = 259200 #3 days
  workspace_id    = aws_grafana_workspace.workshop.id
}


resource "aws_grafana_role_association" "example" {
  count        = length(var.identitystore_admins_info)
  role         = "ADMIN"
  user_ids     = aws_identitystore_user.example[*].user_id
  workspace_id = aws_grafana_workspace.workshop.id
}