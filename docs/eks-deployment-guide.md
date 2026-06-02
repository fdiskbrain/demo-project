# EKS Deployment Guide

This guide explains how to deploy and manage EKS clusters using Terraform.

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0.0 installed
3. **kubectl** installed for Kubernetes cluster management
4. **aws-iam-authenticator** for authentication

## Architecture Overview

The EKS deployment includes:
- EKS Cluster with managed control plane
- Managed Node Groups across 3 Availability Zones
- IAM roles and policies for cluster and nodes
- Security groups for network isolation
- CloudWatch Logs for cluster monitoring

## Environment Configuration

### Development Environment
- Kubernetes Version: 1.34
- Instance Type: t3.medium
- Nodes: 1-3 (desired: 1)
- Public Endpoint: Disabled

### Test Environment
- Kubernetes Version: 1.34
- Instance Type: t3.medium
- Nodes: 1-3 (desired: 1)
- Public Endpoint: Disabled

### Staging Environment
- Kubernetes Version: 1.34
- Instance Type: t3.medium
- Nodes: 2-5 (desired: 2)
- Public Endpoint: Disabled

### Performance Test Environment
- Kubernetes Version: 1.34
- Instance Type: t3.large
- Nodes: 2-10 (desired: 3)
- Public Endpoint: Disabled

### Production Environment
- Kubernetes Version: 1.34
- Instance Type: t3.large
- Nodes: 3-15 (desired: 3)
- Public Endpoint: Disabled

## Deployment Steps

### 1. Initialize Terraform

```bash
cd tf
terraform init
```

### 2. Plan Deployment

For development environment:
```bash
terraform plan -var-file="envs/terraform_dev.tfvars"
```

For production environment:
```bash
terraform plan -var-file="envs/terraform_prod.tfvars"
```

### 3. Apply Configuration

```bash
terraform apply -var-file="envs/terraform_dev.tfvars"
```

Type `yes` when prompted to confirm.

### 4. Configure kubectl

After deployment, configure kubectl to connect to the cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name demo-project-dev-eks
```

### 5. Verify Cluster Access

```bash
kubectl get nodes
kubectl get pods -A
```

## Subnet Tagging

The VPC module automatically applies required Kubernetes tags to subnets:

- **All subnets**: `kubernetes.io/cluster/{cluster-name} = shared`
- **Public subnets**: `kubernetes.io/role/elb = 1`
- **Private subnets**: `kubernetes.io/role/internal-elb = 1`

These tags enable:
- Automatic subnet discovery by EKS
- Load balancer provisioning in correct subnets
- Proper routing for external and internal services

## Scaling Node Groups

To scale the node group, update the tfvars file:

```hcl
eks_min_nodes     = 2
eks_max_nodes     = 10
eks_desired_nodes = 5
```

Then apply:
```bash
terraform apply -var-file="envs/terraform_dev.tfvars"
```

## Upgrading Kubernetes Version

To upgrade the Kubernetes version:

1. Update `kubernetes_version` in the tfvars file
2. Run `terraform plan` to review changes
3. Apply the changes

**Note**: Upgrades are performed in-place and may cause brief API server unavailability.

## Monitoring

Cluster logs are sent to CloudWatch Logs with the following log types enabled:
- api
- audit
- authenticator
- controllerManager
- scheduler

View logs in AWS Console under CloudWatch > Log Groups > `/aws/eks/{cluster-name}/cluster`

## Security Best Practices

1. **Disable Public Endpoint**: Production clusters should have `eks_enable_public_endpoint = false`
2. **Restrict CIDR Blocks**: Limit API access to specific IP ranges
3. **Use Private Subnets**: Node groups are deployed in private subnets only
4. **IAM Roles**: Least privilege policies are applied to cluster and node roles
5. **Encryption**: etcd encryption is enabled by default

## Troubleshooting

### Cluster Creation Fails

Check CloudWatch logs for detailed error messages:
```bash
aws logs filter-log-events \
  --log-group-name "/aws/eks/demo-project-dev-eks/cluster" \
  --start-time $(date -d '1 hour ago' +%s%3N)
```

### Nodes Not Joining Cluster

1. Verify subnet tags are correctly applied
2. Check security group rules allow communication
3. Verify IAM roles have correct policies attached
4. Check node group status:
   ```bash
   aws eks describe-nodegroup \
     --cluster-name demo-project-dev-eks \
     --nodegroup-name demo-project-dev-eks-node-group
   ```

### kubectl Connection Issues

1. Verify kubeconfig is updated:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name demo-project-dev-eks
   ```
2. Check AWS credentials have EKS permissions
3. Verify cluster is in ACTIVE state

## Cleanup

To destroy the EKS cluster:

```bash
terraform destroy -var-file="envs/terraform_dev.tfvars"
```

**Warning**: This will delete all resources including data stored on nodes. Ensure backups are created before destruction.

## Cost Optimization

1. Use spot instances for non-production environments:
   ```hcl
   eks_capacity_type = "SPOT"
   ```

2. Scale down during off-hours using Kubernetes autoscaler

3. Right-size instance types based on workload requirements

4. Monitor costs using AWS Cost Explorer with EKS resource tags
