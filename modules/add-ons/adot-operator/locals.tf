locals {
  name                       = "adot"
  eks_addon_role_name        = "eks:addon-manager"
  eks_addon_clusterrole_name = "eks:addon-manager-otel"
  addon_namespace            = "opentelemetry-operator-system"
}
