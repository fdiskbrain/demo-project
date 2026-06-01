variable "name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs (3 subnets total - 1 per AZ)"
  type        = list(string)
  default = [
    # AZ1 Public Subnet
    "10.0.1.0/24", # public-subnet-az1
    # AZ2 Public Subnet
    "10.0.2.0/24", # public-subnet-az2
    # AZ3 Public Subnet
    "10.0.3.0/24", # public-subnet-az3
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDRs (3 subnets total - 1 per AZ)"
  type        = list(string)
  default = [
    # AZ1 Private Subnet
    "10.0.101.0/24", # private-subnet-az1
    # AZ2 Private Subnet
    "10.0.102.0/24", # private-subnet-az2
    # AZ3 Private Subnet
    "10.0.103.0/24", # private-subnet-az3
  ]
}

variable "single_nat_gateway" {
  description = "Whether to use single NAT gateway"
  type        = bool
  default     = false # Set to false for one NAT Gateway per AZ
}

variable "one_nat_gateway_per_az" {
  description = "Whether to create one NAT gateway per availability zone"
  type        = bool
  default     = true # One NAT Gateway per AZ for high availability
}

variable "project" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}

# EKS Configuration Variables
variable "enable_eks" {
  description = "Whether to enable EKS cluster deployment"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "eks_instance_types" {
  description = "List of instance types for EKS node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_min_nodes" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 3
}

variable "eks_desired_nodes" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_enable_public_endpoint" {
  description = "Whether to enable public endpoint for EKS cluster"
  type        = bool
  default     = false
}

# RDS Aurora Configuration Variables
variable "enable_rds" {
  description = "Whether to enable RDS Aurora cluster deployment"
  type        = bool
  default     = false
}

variable "rds_instances" {
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
variable "rds_engine" {
  description = "The name of the database engine to be used for this DB cluster"
  type        = string
  default     = "aurora-mysql"

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.rds_engine)
    error_message = "Engine must be either aurora-mysql or aurora-postgresql."
  }
}

variable "rds_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0.mysql_aurora.3.05.2"
}

variable "rds_engine_mode" {
  description = "The database engine mode"
  type        = string
  default     = "provisioned"

  validation {
    condition     = contains(["provisioned", "serverless"], var.rds_engine_mode)
    error_message = "Engine mode must be either provisioned or serverless."
  }
}

variable "rds_database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = "mydb"
}

variable "rds_master_username" {
  description = "Username for the master DB user"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "rds_master_password" {
  description = "Password for the master DB user (min 8 characters)"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "rds_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 3306
}

variable "rds_instance_class" {
  description = "Instance class to use when creating instances"
  type        = string
  default     = "db.r6g.large"
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain backups for"
  type        = number
  default     = 7

  validation {
    condition     = var.rds_backup_retention_period >= 1 && var.rds_backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

variable "rds_preferred_backup_window" {
  description = "Daily time range during which the backups are created"
  type        = string
  default     = "02:00-04:00"
}

variable "rds_preferred_maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:04:30"
}

variable "rds_monitoring_interval" {
  description = "Interval to monitor the underlying health of your DB instances (in seconds). Valid values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.rds_monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "rds_performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}

variable "rds_performance_insights_retention_period" {
  description = "The amount of time to retain performance insights data"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 31, 93, 185, 366, 731], var.rds_performance_insights_retention_period)
    error_message = "Performance Insights retention period must be one of: 7, 31, 93, 185, 366, 731 days."
  }
}

variable "rds_serverlessv2_scaling_configuration" {
  description = "Serverless v2 scaling configuration for RDS Aurora (min and max capacity)"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}
