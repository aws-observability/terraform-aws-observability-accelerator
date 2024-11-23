resource "random_password" "opensearch_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  opensearch_master_user_name     = var.master_user_name
  opensearch_master_user_password = var.master_user_password == "" ? random_password.opensearch_master_password.result : var.master_user_password 
  availability_zone               = var.availability_zone == "" ? "${var.aws_region}a" : var.availability_zone
}
