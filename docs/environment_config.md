# Environment Configuration Comparison

## Overview

This document describes the subnet planning for different environments, ensuring no CIDR overlap and appropriate sizing for each environment.

---

## Environment Summary

| Environment | VPC CIDR | Subnet Size | Public Subnets | Private Subnets | NAT Gateway | Use Case |
|-------------|----------|-------------|----------------|-----------------|-------------|----------|
| **Dev** | 10.0.0.0/16 | /24 (256 IPs) | 3 | 3 | Single (shared) | Development & testing |
| **Test** | 10.1.0.0/16 | /24 (256 IPs) | 3 | 3 | Single (shared) | Integration testing |
| **Staging** | 10.2.0.0/16 | /20 (4096 IPs) | 3 | 3 | One per AZ | Pre-production validation |
| **Perf** | 10.3.0.0/16 | /20 (4096 IPs) | 3 | 3 | One per AZ | Performance testing |
| **Prod** | 10.4.0.0/16 | /20 (4096 IPs) | 3 | 3 | One per AZ | Production workloads |

---

## Detailed Configuration

### 1. Dev Environment (`terraform_dev.tfvars`)

**Purpose**: Development and basic testing  
**VPC CIDR**: `10.0.0.0/16`

#### Public Subnets (/24 - 256 IPs each)
- `10.0.1.0/24` - us-east-1a
- `10.0.2.0/24` - us-east-1b
- `10.0.3.0/24` - us-east-1c

#### Private Subnets (/24 - 256 IPs each)
- `10.0.101.0/24` - us-east-1a
- `10.0.102.0/24` - us-east-1b
- `10.0.103.0/24` - us-east-1c

#### NAT Gateway
- **Configuration**: Single shared NAT gateway
- **Cost Optimization**: Lower cost for dev environment

---

### 2. Test Environment (`terraform_test.tfvars`)

**Purpose**: Integration and QA testing  
**VPC CIDR**: `10.1.0.0/16`

#### Public Subnets (/24 - 256 IPs each)
- `10.1.1.0/24` - us-east-1a
- `10.1.2.0/24` - us-east-1b
- `10.1.3.0/24` - us-east-1c

#### Private Subnets (/24 - 256 IPs each)
- `10.1.101.0/24` - us-east-1a
- `10.1.102.0/24` - us-east-1b
- `10.1.103.0/24` - us-east-1c

#### NAT Gateway
- **Configuration**: Single shared NAT gateway
- **Cost Optimization**: Lower cost for test environment

---

### 3. Staging Environment (`terraform_staging.tfvars`)

**Purpose**: Pre-production validation and UAT  
**VPC CIDR**: `10.2.0.0/16`

#### Public Subnets (/20 - 4096 IPs each)
- `10.2.16.0/20` - us-east-1a
- `10.2.32.0/20` - us-east-1b
- `10.2.48.0/20` - us-east-1c

#### Private Subnets (/20 - 4096 IPs each)
- `10.2.64.0/20` - us-east-1a
- `10.2.80.0/20` - us-east-1b
- `10.2.96.0/20` - us-east-1c

#### NAT Gateway
- **Configuration**: One NAT gateway per AZ
- **High Availability**: Better availability for staging

---

### 4. Performance Test Environment (`terraform_perf.tfvars`)

**Purpose**: Load testing and performance validation  
**VPC CIDR**: `10.3.0.0/16`

#### Public Subnets (/20 - 4096 IPs each)
- `10.3.16.0/20` - us-east-1a
- `10.3.32.0/20` - us-east-1b
- `10.3.48.0/20` - us-east-1c

#### Private Subnets (/20 - 4096 IPs each)
- `10.3.64.0/20` - us-east-1a
- `10.3.80.0/20` - us-east-1b
- `10.3.96.0/20` - us-east-1c

#### NAT Gateway
- **Configuration**: One NAT gateway per AZ
- **High Availability**: Support high traffic loads

---

### 5. Production Environment (`terraform_prod.tfvars`)

**Purpose**: Production workloads  
**VPC CIDR**: `10.4.0.0/16`

#### Public Subnets (/20 - 4096 IPs each)
- `10.4.16.0/20` - us-east-1a
- `10.4.32.0/20` - us-east-1b
- `10.4.48.0/20` - us-east-1c

#### Private Subnets (/20 - 4096 IPs each)
- `10.4.64.0/20` - us-east-1a
- `10.4.80.0/20` - us-east-1b
- `10.4.96.0/20` - us-east-1c

#### NAT Gateway
- **Configuration**: One NAT gateway per AZ
- **High Availability**: Maximum availability for production

---

## CIDR Allocation Strategy

### Non-Overlapping Design

Each environment uses a separate /16 CIDR block to ensure complete isolation:

```
10.0.0.0/8 (Private Network Range)
├── 10.0.0.0/16  - Dev Environment
│   ├── 10.0.1.0/24 - 10.0.3.0/24    (Public)
│   └── 10.0.101.0/24 - 10.0.103.0/24 (Private)
│
├── 10.1.0.0/16  - Test Environment
│   ├── 10.1.1.0/24 - 10.1.3.0/24    (Public)
│   └── 10.1.101.0/24 - 10.1.103.0/24 (Private)
│
├── 10.2.0.0/16  - Staging Environment
│   ├── 10.2.16.0/20 - 10.2.48.0/20  (Public)
│   └── 10.2.64.0/20 - 10.2.96.0/20  (Private)
│
├── 10.3.0.0/16  - Perf Environment
│   ├── 10.3.16.0/20 - 10.3.48.0/20  (Public)
│   └── 10.3.64.0/20 - 10.3.96.0/20  (Private)
│
└── 10.4.0.0/16  - Prod Environment
    ├── 10.4.16.0/20 - 10.4.48.0/20  (Public)
    └── 10.4.64.0/20 - 10.4.96.0/20  (Private)
```

### Subnet Sizing Rationale

#### /24 Subnets (Dev & Test)
- **IPs per subnet**: 256
- **Use case**: Small-scale development and testing
- **Benefits**: 
  - Cost-effective
  - Sufficient for limited resources
  - Easier to manage

#### /20 Subnets (Staging, Perf, Prod)
- **IPs per subnet**: 4,096
- **Use case**: Large-scale workloads
- **Benefits**:
  - Supports auto-scaling groups
  - Room for growth
  - Better for load testing
  - Production-ready capacity

---

## NAT Gateway Configuration

### Single NAT Gateway (Dev & Test)
- **Cost**: ~$32.40/month
- **Availability**: Lower (single point of failure)
- **Use case**: Cost-sensitive environments

### One NAT Per AZ (Staging, Perf, Prod)
- **Cost**: ~$97.20/month
- **Availability**: High (no single point of failure)
- **Use case**: Production-critical environments

---

## Deployment Commands

### Deploy Dev Environment
```bash
cd tf
terraform apply -var-file="envs/terraform_dev.tfvars"
```

### Deploy Test Environment
```bash
cd tf
terraform apply -var-file="envs/terraform_test.tfvars"
```

### Deploy Staging Environment
```bash
cd tf
terraform apply -var-file="envs/terraform_staging.tfvars"
```

### Deploy Perf Environment
```bash
cd tf
terraform apply -var-file="envs/terraform_perf.tfvars"
```

### Deploy Prod Environment
```bash
cd tf
terraform apply -var-file="envs/terraform_prod.tfvars"
```

---

## Verification Checklist

After deployment, verify:

- [ ] No CIDR overlaps between environments
- [ ] Correct subnet sizes per environment
- [ ] NAT gateway configuration matches requirements
- [ ] All subnets in correct AZs
- [ ] Route tables properly configured
- [ ] Tags correctly applied

---

## Cost Comparison

| Environment | Monthly NAT Cost | Subnet Capacity | Total IPs |
|-------------|------------------|-----------------|-----------|
| Dev | ~$32.40 | /24 (256) | 1,536 |
| Test | ~$32.40 | /24 (256) | 1,536 |
| Staging | ~$97.20 | /20 (4096) | 24,576 |
| Perf | ~$97.20 | /20 (4096) | 24,576 |
| Prod | ~$97.20 | /20 (4096) | 24,576 |

**Total Monthly NAT Cost (all environments)**: ~$356.40

---

## Best Practices

1. **Environment Isolation**: Each environment has completely separate CIDR ranges
2. **Right-Sizing**: Dev/test use smaller subnets, prod/staging use larger
3. **High Availability**: Critical environments have NAT per AZ
4. **Cost Optimization**: Non-critical environments share NAT gateways
5. **Scalability**: Larger subnets in prod allow for auto-scaling
6. **Future Expansion**: Plenty of room in 10.0.0.0/8 for additional environments

---

## Future Considerations

- Add more environments as needed (e.g., DR, sandbox)
- Consider VPC peering for cross-environment communication
- Implement Transit Gateway for complex multi-VPC architectures
- Monitor IP utilization and adjust subnet sizes if needed
- Add IPv6 support if required

---

**Last Updated**: $(date +%Y-%m-%d)  
**Version**: 2.0  
**Status**: ✅ All environments configured with non-overlapping CIDRs
