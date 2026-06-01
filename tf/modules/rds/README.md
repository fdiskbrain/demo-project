# RDS Aurora Module

This module creates an AWS RDS Aurora MySQL cluster with high availability and monitoring capabilities.

## Features

- **Aurora MySQL Cluster**: Supports both provisioned and serverless modes (including Serverless v2)
- **Multi-AZ Deployment**: Distributes instances across multiple availability zones for high availability
- **Automated Backups**: Configurable backup retention period (1-35 days)
- **Performance Insights**: Monitors database performance metrics
- **Enhanced Monitoring**: Provides OS-level metrics for DB instances
- **Encryption**: Storage encryption enabled by default
- **Security Groups**: Configurable security groups for access control
- **Serverless v2 Support**: Auto-scaling capacity configuration for serverless workloads

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| rds_cluster | terraform-aws-modules/rds-aurora/aws | ~> 10.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_identifier | The identifier for the RDS cluster | `string` | `"aurora-cluster-demo"` | no |
| engine | The name of the database engine | `string` | `"aurora-mysql"` | no |
| engine_version | The version of the database engine | `string` | `"8.0.mysql_aurora.3.05.2"` | no |
| engine_mode | The database engine mode (provisioned or serverless) | `string` | `"provisioned"` | no |
| storage_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| database_name | Name for an automatically created database | `string` | `"mydb"` | no |
| master_username | Username for the master DB user | `string` | n/a | yes |
| master_password | Password for the master DB user | `string` | n/a | yes |
| port | The port on which the DB accepts connections | `number` | `3306` | no |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| db_subnet_group_name | Name of DB subnet group | `string` | `""` | no |
| security_group_ids | List of security groups | `list(string)` | `[]` | no |
| availability_zones | List of EC2 Availability Zones | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| instances | Map of cluster instances | `map(object({...}))` | `{one = {}, two = {}}` | no |
| instance_class | Instance class for creating instances | `string` | `"db.r6g.large"` | no |
| backup_retention_period | Number of days to retain backups | `number` | `7` | no |
| preferred_backup_window | Daily time range for backups | `string` | `"02:00-04:00"` | no |
| preferred_maintenance_window | Weekly time range for maintenance | `string` | `"Mon:04:00-Mon:04:30"` | no |
| monitoring_interval | Enhanced monitoring interval in seconds | `number` | `60` | no |
| monitoring_role_arn | ARN of the IAM role for enhanced monitoring | `string` | `null` | no |
| performance_insights_enabled | Whether Performance Insights are enabled | `bool` | `true` | no |
| performance_insights_retention_period | Retention period for performance insights | `number` | `7` | no |
| create_monitoring_role | Create IAM role for enhanced monitoring | `bool` | `true` | no |
| cluster_parameters | List of DB cluster parameters | `list(object({...}))` | `[]` | no |
| instance_parameters | List of DB instance parameters | `list(object({...}))` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| serverlessv2_scaling_configuration | Serverless v2 scaling configuration (min/max capacity) | `object({min_capacity = number, max_capacity = number})` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The RDS cluster identifier |
| cluster_arn | The RDS cluster ARN |
| cluster_endpoint | Writer endpoint for the cluster |
| reader_endpoint | Read-only endpoint for the cluster |
| cluster_port | The database port |
| cluster_database_name | The database name |
| cluster_master_username | The master username (sensitive) |
| cluster_security_groups | List of security groups associated with the cluster |
| cluster_instances | Map of cluster instances with their attributes |
| db_subnet_group_name | The db subnet group name |
| enhanced_monitoring_iam_role_arn | ARN of the enhanced monitoring role |

## Usage

### Basic Example (Provisioned Mode)

```hcl
module "rds" {
  source = "./modules/rds"

  # Cluster configuration
  cluster_identifier = "my-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.05.2"
  
  # Database credentials
  database_name   = "mydb"
  master_username = "admin"
  master_password = var.db_password
  
  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # Availability zones
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Instance configuration
  instances = {
    one = {
      instance_class = "db.r6g.large"
      promotion_tier = 1
    }
    two = {
      instance_class = "db.r6g.large"
      promotion_tier = 2
    }
  }
  
  # Backup configuration
  backup_retention_period = 7
  
  tags = {
    Environment = "production"
  }
}
```

### Serverless v2 Example

``hcl
module "rds" {
  source = "./modules/rds"

  cluster_identifier = "my-aurora-serverless"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.05.2"
  engine_mode        = "provisioned"  # Serverless v2 uses provisioned mode
  
  database_name   = "mydb"
  master_username = "admin"
  master_password = var.db_password
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Serverless v2 instances
  instances = {
    one = {
      instance_class = "db.serverless"
      promotion_tier = 1
    }
  }
  
  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5  # Minimum ACU (Aurora Capacity Units)
    max_capacity = 10   # Maximum ACU
  }
  
  backup_retention_period = 7
  
  tags = {
    Environment = "development"
  }
}
```

## Security Best Practices

1. **Use Secrets Manager**: Store database credentials in AWS Secrets Manager instead of hardcoding them
2. **Enable Encryption**: Always enable storage encryption (`storage_encrypted = true`)
3. **Private Subnets**: Deploy RDS instances in private subnets only
4. **Security Groups**: Restrict access using security groups to specific CIDR ranges
5. **Strong Passwords**: Use strong passwords (minimum 8 characters, mix of letters, numbers, symbols)
6. **Backup Retention**: Set appropriate backup retention period based on compliance requirements
7. **Monitoring**: Enable enhanced monitoring and Performance Insights for production databases
8. **IAM Authentication**: Consider using IAM database authentication for additional security

## Instance Class Recommendations

### Provisioned Mode

| Environment | Recommended Instance Class | Use Case |
|-------------|---------------------------|----------|
| Development | `db.t3.medium` | Low-cost testing and development |
| Testing | `db.t3.large` | Integration and load testing |
| Staging | `db.r6g.large` | Pre-production validation |
| Production | `db.r6g.xlarge` or higher | High-performance production workloads |

### Serverless v2 Mode

| Workload Type | Min Capacity (ACU) | Max Capacity (ACU) | Use Case |
|---------------|-------------------|-------------------|----------|
| Development | 0.5 | 2 | Low-traffic dev environments |
| Testing | 1 | 5 | Integration testing with variable loads |
| Staging | 2 | 10 | Pre-production with moderate traffic |
| Production | 4 | 32 | Production workloads with auto-scaling |

**Note**: 1 ACU ≈ 2 GiB memory, corresponding CPU and networking capacity. Serverless v2 automatically scales based on demand.

## Backup Strategy

- **Development**: 7 days retention
- **Testing/Staging**: 7-14 days retention
- **Production**: 14-35 days retention (based on compliance requirements)

## Monitoring

The module enables:
- **Enhanced Monitoring**: OS-level metrics (CPU, memory, disk I/O)
- **Performance Insights**: Database performance metrics and query analysis
- **CloudWatch Logs**: Error logs, slow query logs, general logs (configurable)

## Notes

- The module creates 2 instances by default for high availability
- Instances are distributed across availability zones automatically
- Automatic failover is enabled for multi-AZ deployments
- Maintenance windows should be scheduled during low-traffic periods
- Backup windows should not overlap with maintenance windows

## Version 10.0 Upgrade Notes

This module uses `terraform-aws-modules/rds-aurora/aws` version 10.0, which includes:

### New Features
- **Serverless v2 Support**: Enhanced auto-scaling with `serverlessv2_scaling_configuration`
- **Improved Instance Management**: Better handling of instance classes and promotion tiers
- **Enhanced Monitoring**: More granular control over monitoring intervals

### Breaking Changes from v8.x
- Some parameter names may have changed
- Review the [official module changelog](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/master/CHANGELOG.md) before upgrading
- Test thoroughly in non-production environments first

### Migration from v8.x
1. Update module version to `~> 10.0`
2. Review and update any deprecated parameters
3. Add `serverlessv2_scaling_configuration` if using serverless v2
4. Run `terraform plan` to review changes
5. Apply changes after verification
