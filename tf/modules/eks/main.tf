# EKS Cluster Module using terraform-aws-modules/eks/aws
# This module wraps the official community module for simplified configuration

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name    = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # VPC Configuration
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : var.subnet_ids

  # Cluster Endpoint Access
  endpoint_public_access  = var.enable_public_endpoint

  # Public access CIDRs (restricted when public endpoint is enabled)
  # cluster_endpoint_public_access_cidrs = var.public_access_cidrs

  # CloudWatch Logging
  # cluster_enabled_log_types = var.enabled_cluster_log_types

  # Managed Node Groups
  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.desired_nodes

      labels = var.node_labels

      tags = var.tags
    }
  }

  # Tags
  tags = var.tags
}
