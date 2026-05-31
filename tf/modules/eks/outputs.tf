# Outputs for EKS Module (using terraform-aws-modules/eks/aws)

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_managed_node_groups" {
  description = "The ID of the default node group"
  value       = module.eks.eks_managed_node_groups
}

output "oidc_provider" {
  description = "The oidc_provider"
  value       = module.eks.oidc_provider
}

output "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}


