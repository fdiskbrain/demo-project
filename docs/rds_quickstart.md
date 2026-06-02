# RDS Aurora Quick Start Guide

This guide will help you deploy an AWS RDS Aurora MySQL cluster using Terraform.

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create RDS resources

## Step 1: Configure Environment Variables

Edit the environment-specific `.tfvars` file in `tf/envs/`:

```bash
# For development environment
vim tf/envs/terraform_dev.tfvars
```

Update the RDS configuration section:

```hcl
# RDS Aurora Configuration
enable_rds                              = true
rds_engine                              = "aurora-mysql"
rds_engine_version                      = "8.0.mysql_aurora.3.05.2"
rds_engine_mode                         = "provisioned"
rds_database_name                       = "appdb"
rds_master_username                     = "admin"
rds_master_password                     = "YourSecurePassword123!"
rds_port                                = 3306
rds_instance_class                      = "db.t3.medium"
rds_backup_retention_period             = 7
rds_preferred_backup_window             = "02:00-04:00"
rds_preferred_maintenance_window        = "Mon:04:00-Mon:04:30"
rds_monitoring_interval                 = 60
rds_performance_insights_enabled        = true
rds_performance_insights_retention_period = 7
```

**Important**: Change `rds_master_password` to a strong, unique password!

### Serverless v2 Configuration (Optional)

For auto-scaling workloads, you can use Serverless v2:

``hcl
# RDS Aurora Serverless v2 Configuration
enable_rds                              = true
rds_engine                              = "aurora-mysql"
rds_engine_version                      = "8.0.mysql_aurora.3.05.2"
rds_engine_mode                         = "provisioned"  # Serverless v2 uses provisioned mode
rds_database_name                       = "appdb"
rds_master_username                     = "admin"
rds_master_password                     = "YourSecurePassword123!"
rds_port                                = 3306
rds_instance_class                      = "db.serverless"  # Use serverless instance class
rds_backup_retention_period             = 7
rds_preferred_backup_window             = "02:00-04:00"
rds_preferred_maintenance_window        = "Mon:04:00-Mon:04:30"
rds_monitoring_interval                 = 60
rds_performance_insights_enabled        = true
rds_performance_insights_retention_period = 7

# Serverless v2 scaling configuration
rds_serverlessv2_scaling_configuration = {
  min_capacity = 0.5  # Minimum ACU (Aurora Capacity Units)
  max_capacity = 10   # Maximum ACU
}
```

**Note**: With Serverless v2, the database automatically scales between min and max capacity based on demand.

## Step 2: Initialize Terraform

```bash
cd tf
terraform init
```

## Step 3: Review the Plan

```bash
# For development environment
terraform plan -var-file="envs/terraform_dev.tfvars"
```

Review the output to ensure:
- RDS cluster will be created in private subnets
- Security group allows access from VPC CIDR
- Backup and monitoring settings are correct
- Instance types match your requirements

## Step 4: Apply the Configuration

```bash
# For development environment
terraform apply -var-file="envs/terraform_dev.tfvars"
```

Type `yes` when prompted to confirm.

## Step 5: Verify Deployment

After successful deployment, check the outputs:

```bash
# Get cluster endpoint
terraform output rds_cluster_endpoint

# Get cluster ID
terraform output rds_cluster_id

# Get reader endpoint (for read replicas)
terraform output rds_reader_endpoint
```

## Step 6: Connect to the Database

### Using MySQL Client

```bash
mysql -h <cluster-endpoint> -P 3306 -u admin -p
```

Replace `<cluster-endpoint>` with the value from `terraform output rds_cluster_endpoint`.

### From EKS Cluster

If you have EKS deployed, you can create a Kubernetes secret and connect from pods:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rds-credentials
type: Opaque
data:
  username: <base64-encoded-username>
  password: <base64-encoded-password>
  endpoint: <base64-encoded-endpoint>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rds-config
data:
  DB_HOST: "<cluster-endpoint>"
  DB_PORT: "3306"
  DB_NAME: "appdb"
```

## Production Deployment

### Option 1: Provisioned Mode (Traditional)

For production environments with predictable workloads, update `tf/envs/terraform_prod.tfvars`:

```hcl
# RDS Aurora Configuration - Production (Provisioned)
enable_rds                              = true
rds_engine                              = "aurora-mysql"
rds_engine_version                      = "8.0.mysql_aurora.3.05.2"
rds_engine_mode                         = "provisioned"
rds_database_name                       = "appdb"
rds_master_username                     = "admin"
rds_master_password                     = var.rds_password  # Use variable or Secrets Manager
rds_port                                = 3306
rds_instance_class                      = "db.r6g.xlarge"   # Higher performance instance
rds_backup_retention_period             = 30                # Longer retention for compliance
rds_preferred_backup_window             = "03:00-05:00"
rds_preferred_maintenance_window        = "Sun:04:00-Sun:04:30"
rds_monitoring_interval                 = 60
rds_performance_insights_enabled        = true
rds_performance_insights_retention_period = 31              # Longer retention for analysis
```

### Option 2: Serverless v2 Mode (Auto-scaling)

For production environments with variable workloads:

```hcl
# RDS Aurora Configuration - Production (Serverless v2)
enable_rds                              = true
rds_engine                              = "aurora-mysql"
rds_engine_version                      = "8.0.mysql_aurora.3.05.2"
rds_engine_mode                         = "provisioned"
rds_database_name                       = "appdb"
rds_master_username                     = "admin"
rds_master_password                     = var.rds_password
rds_port                                = 3306
rds_instance_class                      = "db.serverless"   # Serverless v2 instance
rds_backup_retention_period             = 30
rds_preferred_backup_window             = "03:00-05:00"
rds_preferred_maintenance_window        = "Sun:04:00-Sun:04:30"
rds_monitoring_interval                 = 60
rds_performance_insights_enabled        = true
rds_performance_insights_retention_period = 31

# Serverless v2 scaling configuration
rds_serverlessv2_scaling_configuration = {
  min_capacity = 4    # Minimum 4 ACU for baseline performance
  max_capacity = 32   # Maximum 32 ACU for peak loads
}
```

**Choosing Between Modes:**
- **Provisioned**: Best for predictable, consistent workloads. Fixed cost, guaranteed performance.
- **Serverless v2**: Best for variable workloads. Pay only for what you use, automatic scaling.

Apply for production:

```bash
terraform plan -var-file="envs/terraform_prod.tfvars"
terraform apply -var-file="envs/terraform_prod.tfvars"
```

## Security Recommendations

1. **Use AWS Secrets Manager** for password management:
   ```hcl
   rds_master_password = data.aws_secretsmanager_secret_version.db_password.secret_string
   ```

2. **Restrict Security Group Access**:
   - Only allow specific application security groups
   - Don't open to entire VPC CIDR in production

3. **Enable Encryption at Rest**: Already enabled by default (`storage_encrypted = true`)

4. **Enable Encryption in Transit**: Use SSL/TLS connections

5. **Implement IAM Database Authentication** for additional security layer

## Monitoring and Maintenance

### CloudWatch Alarms

Set up alarms for:
- CPU utilization > 80%
- Freeable memory < 20%
- Disk queue depth > 10
- Read/write IOPS spikes

### Performance Insights

Access Performance Insights via AWS Console:
1. Navigate to RDS → Performance Insights
2. Select your cluster
3. Analyze top SQL queries and wait events

### Backup Management

- Backups are automated based on `preferred_backup_window`
- Manual snapshots can be created via AWS Console or CLI
- Test restore procedures regularly

## Troubleshooting

### Connection Issues

1. **Check Security Groups**: Ensure your client IP is allowed
2. **Verify Subnet Routing**: RDS must be in private subnets with proper routing
3. **Check Network ACLs**: Ensure traffic is not blocked

### Performance Issues

1. **Check Performance Insights**: Identify slow queries
2. **Monitor CloudWatch Metrics**: CPU, memory, IOPS
3. **Consider Scaling**: Upgrade instance class if needed

### High Availability

- Verify instances are distributed across AZs
- Test failover by promoting a read replica
- Monitor replication lag metrics

## Cleanup

To destroy the RDS cluster:

```bash
terraform destroy -var-file="envs/terraform_dev.tfvars"
```

**Warning**: This will delete all data! Create manual snapshots before destroying if you need to preserve data.

## Additional Resources

- [AWS RDS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)
- [Terraform AWS RDS Aurora Module](https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest)
- [MySQL Aurora Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.BestPractices.html)
