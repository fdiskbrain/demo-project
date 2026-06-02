# AWS IAM Policy Templates for Terraform CI/CD

These are example IAM policies for each environment. Adjust permissions based on your specific requirements.

## Dev Environment Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "iam:CreateServiceLinkedRole",
        "logs:*",
        "cloudwatch:*",
        "s3:*",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy"
      ],
      "Resource": "arn:aws:iam::*:role/dev-*"
    }
  ]
}
```

## Staging Environment Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudwatch:*",
        "logs:*",
        "s3:*",
        "route53:*",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/staging-*"
    }
  ]
}
```

## Production Environment Policy (Least Privilege)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "eks:CreateCluster",
        "eks:UpdateClusterConfig",
        "eks:DeleteCluster",
        "eks:CreateNodegroup",
        "eks:UpdateNodegroupConfig",
        "eks:DeleteNodegroup",
        "eks:TagResource",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DeleteAutoScalingGroup",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketEncryption",
        "s3:PutBucketVersioning",
        "route53:CreateHostedZone",
        "route53:DeleteHostedZone",
        "route53:ChangeResourceRecordSets",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "ec2:TerminateInstances",
        "eks:DeleteCluster"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/prod-*",
      "Condition": {
        "StringLike": {
          "iam:PassedToService": "eks.amazonaws.com"
        }
      }
    }
  ]
}
```

## OIDC Trust Policy Template

Replace placeholders with your actual values:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:<GITHUB_OWNER>/<GITHUB_REPO>:environment:<ENVIRONMENT_NAME>",
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

### Example Conditions by Environment

**Dev**:
```json
"token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:environment:dev"
```

**Staging**:
```json
"token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:environment:staging"
```

**Production**:
```json
"token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:environment:production"
```

## S3 Backend Bucket Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-terraform-state-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-terraform-state-bucket",
        "arn:aws:s3:::my-terraform-state-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

## Setup Script for IAM Roles

```bash
#!/bin/bash
# create-iam-roles.sh

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_OWNER="your-org"
GITHUB_REPO="your-repo"

ENVIRONMENTS=("dev" "staging" "perf" "prod")

for ENV in "${ENVIRONMENTS[@]}"; do
  ROLE_NAME="terraform-${ENV}"
  
  # Create trust policy
  cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_OWNER}/${GITHUB_REPO}:environment:${ENV}",
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  # Create role
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document file://trust-policy.json \
    --description "Terraform deployment role for ${ENV} environment"

  # Attach policies (adjust based on your needs)
  if [ "$ENV" = "prod" ]; then
    # Use custom restrictive policy for prod
    aws iam put-role-policy \
      --role-name "${ROLE_NAME}" \
      --policy-name "TerraformProdPermissions" \
      --policy-document file://prod-policy.json
  else
    # Use broader permissions for non-prod
    aws iam attach-role-policy \
      --role-name "${ROLE_NAME}" \
      --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
  fi

  echo "Created role: ${ROLE_NAME}"
  echo "ARN: arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
  
  rm trust-policy.json
done
```

## Important Notes

1. **Principle of Least Privilege**: Always start with minimal permissions and add only what's needed
2. **Environment Isolation**: Each environment should have separate IAM roles
3. **Regular Audits**: Review and audit IAM permissions quarterly
4. **Monitoring**: Enable CloudTrail logging for all IAM actions
5. **MFA**: Require MFA for manual role assumption outside of CI/CD
6. **Rotation**: Regularly rotate any static credentials (though OIDC eliminates this need)
7. **Testing**: Test IAM policies in dev environment before applying to production
