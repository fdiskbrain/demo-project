# EKS Infrastructure Design Document

## Overview

This document describes the design for adding Amazon Elastic Kubernetes Service (EKS) support to the existing VPC infrastructure. The EKS cluster will be deployed across 3 Availability Zones for high availability and fault tolerance.

## Architecture

### Components

1. **EKS Cluster**
   - Managed Kubernetes control plane
   - Deployed across 3 AZs
   - Integrated with existing VPC

2. **Node Groups**
   - Managed node groups for worker nodes
   - Auto-scaling enabled
   - Distributed across all private subnets

3. **Network Integration**
   - Uses existing VPC and subnets
   - Private subnets for worker nodes
   - Public subnets for load balancers
   - Proper subnet tagging for Kubernetes discovery

### Network Requirements

#### Subnet Tags

For EKS to properly discover and utilize subnets, the following tags are required:

**All Subnets:**
- ~~`kubernetes.io/cluster/{cluster-name}` = `shared`~~

**Public Subnets:**
- `kubernetes.io/role/elb` = `1` (for external LoadBalancers)

**Private Subnets:**
- `kubernetes.io/role/internal-elb` = `1` (for internal LoadBalancers)

### Security

- Node groups use IAM roles with least privilege
- Security groups restrict traffic between nodes
- Control plane access restricted via security groups
- Encryption at rest enabled for etcd

## Configuration

### Module Structure

```
tf/modules/eks/
├── main.tf          # EKS cluster and node group definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Module documentation
```

### Integration with VPC

The EKS module will:
1. Accept VPC ID and subnet IDs as inputs
2. Apply required Kubernetes tags to subnets
3. Create security groups for cluster communication
4. Configure IAM roles and policies

### Environment-Specific Settings

| Environment | Kubernetes Version | Instance Type | Min Nodes | Max Nodes | Desired Nodes |
|-------------|-------------------|---------------|-----------|-----------|---------------|
| dev         | 1.34              | t3.medium     | 1         | 3         | 1             |
| test        | 1.34              | t3.medium     | 1         | 3         | 1             |
| staging     | 1.34              | t3.medium     | 2         | 5         | 2             |
| perf        | 1.34              | t3.large      | 2         | 10        | 3             |
| prod        | 1.34              | t3.large      | 3         | 15        | 3             |

## Implementation Plan

1. Create EKS module in `tf/modules/eks/`
2. Update VPC module to add Kubernetes tags
3. Add EKS configuration to main.tf
4. Update environment-specific tfvars files
5. Add outputs for cluster information
6. Test deployment in dev environment

## Dependencies

- AWS Provider >= 6.0.0 (per project requirements)
- terraform-aws-modules/eks module
- Existing VPC module
- AWS IAM permissions for EKS creation

## Rollback Strategy

- Use Terraform state management for safe rollbacks
- Node groups can be scaled down before destruction
- Cluster deletion requires manual confirmation in production
