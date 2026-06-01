# Production Environment - 3 AZ VPC Configuration with EKS Cluster

name        = "demo-vpc"
project     = "demo-project"
environment = "prod"
cidr        = "10.4.0.0/16"

# 3 Availability Zones
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

# 3 Public Subnets (1 per AZ) - /20 for prod environment (larger subnets)
public_subnets = [
  "10.4.16.0/20", # public-subnet-az1 (us-east-1a) - 4096 IPs
  "10.4.32.0/20", # public-subnet-az2 (us-east-1b) - 4096 IPs
  "10.4.48.0/20", # public-subnet-az3 (us-east-1c) - 4096 IPs
]

# 3 Private Subnets (1 per AZ) - /20 for prod environment (larger subnets)
private_subnets = [
  "10.4.64.0/20", # private-subnet-az1 (us-east-1a) - 4096 IPs
  "10.4.80.0/20", # private-subnet-az2 (us-east-1b) - 4096 IPs
  "10.4.96.0/20", # private-subnet-az3 (us-east-1c) - 4096 IPs
]

# NAT Gateway Configuration - High availability for production
single_nat_gateway     = false
one_nat_gateway_per_az = true

# EKS Configuration - Production grade
enable_eks                 = true
kubernetes_version         = "1.34"
eks_instance_types         = ["t3.large"]
eks_min_nodes              = 3
eks_max_nodes              = 15
eks_desired_nodes          = 3
eks_enable_public_endpoint = false

# RDS Aurora Configuration
enable_rds                                = true
rds_engine                                = "aurora-mysql"
rds_engine_version                        = "8.0.mysql_aurora.3.05.2"
rds_engine_mode                           = "provisioned"
rds_database_name                         = "appdb"
rds_master_username                       = "admin"
rds_master_password                       = "DevPassword123!"
rds_port                                  = 3306
rds_instance_class                        = "db.t3.medium"
rds_backup_retention_period               = 7
rds_preferred_backup_window               = "02:00-04:00"
rds_preferred_maintenance_window          = "Mon:04:00-Mon:04:30"
rds_monitoring_interval                   = 60
rds_performance_insights_enabled          = true
rds_performance_insights_retention_period = 7
rds_instances = {
  one = {}
  two = {}
  three = {}
}