locals {
  common_tags = {
    environment = var.environment
    project     = var.project
    owner       = var.owner
  }
}  