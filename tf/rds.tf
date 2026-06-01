# RDS Aurora MySQL Cluster Configuration (Version 10.0)

module "rds" {
  source = "./modules/rds"

  count = var.enable_rds ? 1 : 0

  # Cluster configuration
  cluster_identifier = "${local.name_prefix}-aurora-cluster"
  engine             = var.rds_engine
  engine_version     = var.rds_engine_version

  # Instance configuration
  instance_class = var.rds_instance_class

  # Database configuration
  database_name   = var.rds_database_name
  master_username = var.rds_master_username

  # Password management - use Secrets Manager (recommended for v10.0)
  manage_master_user_password = true

  port = var.rds_port

  # Network configuration
  vpc_id               = module.aws_vpc.vpc_id
  subnet_ids           = module.aws_vpc.private_subnets
  db_subnet_group_name = "${local.name_prefix}-rds-subnet-group"

  # Security group ingress rules (v10.0 format)
  security_group_ingress_rules = {
    mysql_access = {
      cidr_ipv4   = var.cidr
      from_port   = var.rds_port
      to_port     = var.rds_port
      ip_protocol = "tcp"
      description = "Allow MySQL/Aurora access from VPC"
    }
  }

  # Availability zones
  availability_zones = var.azs

  # Instances configuration
  instances = var.rds_instances

  # Serverless v2 scaling configuration (optional, uncomment if using serverless)
  # serverlessv2_scaling_configuration = var.rds_serverlessv2_scaling_configuration

  # Backup configuration
  backup_retention_period      = var.rds_backup_retention_period
  preferred_backup_window      = var.rds_preferred_backup_window
  preferred_maintenance_window = var.rds_preferred_maintenance_window

  # Monitoring (v10.0 uses cluster_monitoring_interval)
  cluster_monitoring_interval = var.rds_monitoring_interval
  create_monitoring_role      = true

  # Performance insights (v10.0 uses cluster_performance_insights_*)
  cluster_performance_insights_enabled          = var.rds_performance_insights_enabled
  cluster_performance_insights_retention_period = var.rds_performance_insights_retention_period

  # CloudWatch logs export
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  # Tags
  tags = local.common_tags
}
