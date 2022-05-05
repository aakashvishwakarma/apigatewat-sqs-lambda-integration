locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Team        = var.team
    Platform    = var.platform_name
  }
}