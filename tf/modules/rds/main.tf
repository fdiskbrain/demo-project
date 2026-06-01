module "rds_cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.0"

  # Cluster configuration
  name           = var.cluster_identifier
  engine         = var.engine
  engine_version = var.engine_version

  # Instance configuration
  cluster_instance_class = var.instance_class

  # Database configuration
  database_name   = var.database_name
  master_username = var.master_username

  # Password management (v10.0 uses Secrets Manager by default)
  manage_master_user_password = var.manage_master_user_password

  port = var.port

  # Network configuration
  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  subnets              = var.subnet_ids

  # Security group configuration (v10.0 uses security_group_ingress_rules)
  security_group_ingress_rules = var.security_group_ingress_rules

  # Availability and scaling
  availability_zones = var.availability_zones

  # Instances configuration
  instances = var.instances

  # Backup configuration
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  # Monitoring (v10.0 uses cluster_monitoring_interval)
  cluster_monitoring_interval = var.cluster_monitoring_interval
  create_monitoring_role      = var.create_monitoring_role

  # Performance insights (v10.0 uses cluster_performance_insights_*)
  cluster_performance_insights_enabled          = var.cluster_performance_insights_enabled
  cluster_performance_insights_retention_period = var.cluster_performance_insights_retention_period

  # Storage encryption
  storage_encrypted = var.storage_encrypted

  # Tags
  tags = merge(local.common_tags, var.tags)

  # CloudWatch logs export
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Serverless v2 configuration (optional)
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration

  # Additional settings
  apply_immediately   = var.apply_immediately
  deletion_protection = var.deletion_protection
}
