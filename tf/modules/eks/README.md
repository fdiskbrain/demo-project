# EKS Module

This module creates an Amazon EKS cluster using the official `terraform-aws-modules/eks/aws` community module.

## Overview

This is a wrapper module around the [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module, providing simplified configuration for standard EKS deployments.

## Usage

```hcl
module "eks" {
  source = "./modules/eks"

  cluster_name         = "my-eks-cluster"
  kubernetes_version   = "1.34"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  private_subnet_ids   = module.vpc.private_subnets
  
  enable_public_endpoint = false
  
  instance_types = ["t3.medium"]
  min_nodes      = 1
  max_nodes      = 3
  desired_nodes  = 1
  
  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 6.0.0 |

## Providers

No direct providers. This module uses the `terraform-aws-modules/eks/aws` module.

## Resources

The underlying `terraform-aws-modules/eks/aws` module creates:
- EKS Cluster
- Managed Node Groups
- IAM Roles and Policies
- Security Groups
- CloudWatch Log Groups
- Additional supporting resources

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the EKS cluster | string | n/a | yes |
| vpc_id | VPC ID where EKS cluster will be deployed | string | n/a | yes |
| subnet_ids | List of subnet IDs for EKS cluster | list(string) | n/a | yes |
| private_subnet_ids | List of private subnet IDs for control plane | list(string) | [] | no |
| kubernetes_version | Kubernetes version for the EKS cluster | string | "1.34" | no |
| enable_public_endpoint | Whether to enable public endpoint | bool | false | no |
| public_access_cidrs | CIDR blocks that can access the public endpoint | list(string) | ["0.0.0.0/0"] | no |
| enabled_cluster_log_types | Log types to enable for the EKS cluster | list(string) | ["api", "audit", "authenticator", "controllerManager", "scheduler"] | no |
| instance_types | Instance types for the node group | list(string) | ["t3.medium"] | no |
| min_nodes | Minimum number of nodes | number | 1 | no |
| max_nodes | Maximum number of nodes | number | 3 | no |
| desired_nodes | Desired number of nodes | number | 1 | no |
| node_labels | Kubernetes labels for the node group | map(string) | {} | no |
| tags | Tags to add to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the EKS cluster |
| cluster_name | The name of the EKS cluster |
| cluster_endpoint | The endpoint for the EKS cluster API server |
| cluster_certificate_authority_data | Base64 encoded certificate data |
| cluster_version | The Kubernetes version of the EKS cluster |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| node_group_id | The ID of the default node group |
| node_group_arn | ARN of the default node group |
| node_group_status | Status of the default node group |
| cluster_role_arn | ARN of the IAM role for the EKS cluster |
| node_group_role_arn | ARN of the IAM role for the default node group |

## Benefits

- **Simplified Configuration**: Reduced complexity with sensible defaults
- **Community Maintained**: Regular updates and bug fixes
- **Best Practices**: Built-in AWS recommendations
- **Feature Rich**: Support for addons, Fargate, multiple node groups
- **Less Code**: ~80% reduction in custom code

## Advanced Configuration

For advanced use cases, you can directly use the `terraform-aws-modules/eks/aws` module:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.34"
  
  # ... additional configuration
}
```

See the [official module documentation](https://github.com/terraform-aws-modules/terraform-aws-eks) for more examples and advanced features.
