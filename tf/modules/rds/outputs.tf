# Outputs for RDS Aurora MySQL Cluster

output "cluster_id" {
  description = "The RDS cluster identifier"
  value       = module.rds_cluster.cluster_id
}

output "cluster_arn" {
  description = "The RDS cluster ARN"
  value       = module.rds_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.rds_cluster.cluster_endpoint
}

output "reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.rds_cluster.cluster_reader_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = module.rds_cluster.cluster_port
}

output "cluster_database_name" {
  description = "The database name"
  value       = module.rds_cluster.cluster_database_name
}

output "cluster_master_username" {
  description = "The master username"
  value       = module.rds_cluster.cluster_master_username
  sensitive   = true
}

output "security_group_id" {
  description = "List of security group ids"
  value       = module.rds_cluster.security_group_id
}

output "cluster_instances" {
  description = "Map of cluster instances with their attributes"
  value       = module.rds_cluster.cluster_instances
}

output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = module.rds_cluster.db_subnet_group_name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.rds_cluster.enhanced_monitoring_iam_role_arn
}
