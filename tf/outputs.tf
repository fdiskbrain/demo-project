# Output definitions for VPC and EKS

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.aws_vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.aws_vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.aws_vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.aws_vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.aws_vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.aws_vpc.natgw_ids
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.aws_vpc.igw_id
}

output "azs" {
  description = "A list of availability zones"
  value       = module.aws_vpc.azs
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.aws_vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.aws_vpc.private_route_table_ids
}

# EKS Outputs
output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_id : null
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : null
}

output "eks_cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_version : null
}

output "eks_managed_node_groups" {
  description = "The ID of the EKS node group"
  value       = var.enable_eks ? module.eks[0].eks_managed_node_groups : null
}
output "oidc_provider" {
  description = "The oidc_provider"
  value       = var.enable_eks ? module.eks[0].oidc_provider : null
}