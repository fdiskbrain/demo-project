# Variables for RDS Aurora MySQL Cluster

variable "cluster_identifier" {
  description = "The identifier for the RDS cluster"
  type        = string
  default     = "aurora-cluster-demo"
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster"
  type        = string
  default     = "aurora-mysql"

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "Engine must be either aurora-mysql or aurora-postgresql."
  }
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = true
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 3306
}

variable "vpc_id" {
  description = "ID of the VPC where the DB subnet group should be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the DB instances can be created"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group"
  type        = string
  default     = ""
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules for RDS cluster (v10.0 format)"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    referenced_security_group_id = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = optional(string)
    description                  = optional(string, "")
  }))
  default = {}
}

variable "availability_zones" {
  description = "List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_class" {
  description = "Instance class to use when creating instances (used as default for all instances)"
  type        = string
  default     = "db.r6g.large"
}

variable "instances" {
  description = "Map of cluster instances and any specific/overridden values"
  type = map(object({
    instance_class      = optional(string)
    publicly_accessible = optional(bool, false)
    promotion_tier      = optional(number, 1)
    identifier          = optional(string)
  }))
  default = {
    one = {}
    two = {}
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "preferred_backup_window" {
  description = "Daily time range during which the backups are created"
  type        = string
  default     = "02:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:04:30"
}

variable "cluster_monitoring_interval" {
  description = "Interval to monitor the underlying health of your DB cluster (in seconds). Valid values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.cluster_monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "create_monitoring_role" {
  description = "Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "cluster_performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled for the cluster"
  type        = bool
  default     = true
}

variable "cluster_performance_insights_retention_period" {
  description = "The amount of time to retain performance insights data"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 31, 93, 185, 366, 731], var.cluster_performance_insights_retention_period)
    error_message = "Performance Insights retention period must be one of: 7, 31, 93, 185, 366, 731 days."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch Logs"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "serverlessv2_scaling_configuration" {
  description = "Serverless v2 scaling configuration. Only used when using serverless instances"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = {
    ManagedBy = "Terraform"
  }
}
