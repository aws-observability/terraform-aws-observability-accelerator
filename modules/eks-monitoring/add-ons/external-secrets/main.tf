module "external_secrets" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/external-secrets?ref=v4.28.0"
  count  = var.enable_external_secrets ? 1 : 0

  helm_config   = var.helm_config
  addon_context = var.addon_context
}

data "aws_region" "current" {}

#---------------------------------------------------------------
# External Secrets Operator - Secret
#---------------------------------------------------------------

resource "aws_kms_key" "secrets" {
  enable_key_rotation = true
}

module "cluster_secretstore_role" {
  source                      = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/irsa?ref=v4.28.0"
  kubernetes_namespace        = local.namespace
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.cluster_secretstore_sa
  irsa_iam_policies           = [aws_iam_policy.cluster_secretstore.arn]
  eks_cluster_id              = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn       = var.addon_context.eks_oidc_provider_arn
  depends_on                  = [module.external_secrets]
}

resource "aws_iam_policy" "cluster_secretstore" {
  name_prefix = local.cluster_secretstore_sa
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "${aws_secretsmanager_secret.secret.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${aws_kms_key.secrets.arn}"
    }
  ]
}
POLICY
}

resource "kubectl_manifest" "cluster_secretstore" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: ${local.cluster_secretstore_name}
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${data.aws_region.current.name}
      auth:
        jwt:
          serviceAccountRef:
            name: ${local.cluster_secretstore_sa}
            namespace: ${local.namespace}
YAML
  depends_on = [module.external_secrets]
}

resource "aws_secretsmanager_secret" "secret" {
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    GF_SECURITY_ADMIN_APIKEY = var.grafana_api_key
  })
}

resource "kubectl_manifest" "secret" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${local.name}-sm
  namespace: ${var.target_secret_namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${local.cluster_secretstore_name}
    kind: ClusterSecretStore
  target:
    name: ${var.target_secret_name}
  dataFrom:
  - extract:
      key: ${aws_secretsmanager_secret.secret.name}
YAML
  depends_on = [module.external_secrets]
}
