# Terraform CI/CD Setup Guide

This guide explains how to set up and configure the GitHub Actions CI/CD pipeline for Terraform infrastructure management.

## Prerequisites

1. **GitHub Repository** with appropriate permissions
2. **AWS Account** with IAM roles configured
3. **Terraform Backend** (S3 + DynamoDB recommended)
4. **GitHub Organization** with team structure

## Step 1: Configure AWS IAM Roles

Create IAM roles for each environment with OIDC trust relationship:

### Create OIDC Provider

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e38db1e8f
```

### Create Environment Roles

For each environment (dev, staging, perf, prod), create an IAM role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:environment:<ENVIRONMENT>"
        }
      }
    }
  ]
}
```

Attach appropriate policies (e.g., `AmazonVPCFullAccess`, `AmazonEKS_FullAccess`).

## Step 2: Configure GitHub Secrets

Navigate to **Settings → Secrets and variables → Actions** and add:

### Required Secrets

| Secret Name | Description | Example |
|------------|-------------|---------|
| `AWS_ROLE_ARN_DEV` | IAM Role ARN for dev environment | `arn:aws:iam::123456789:role/terraform-dev` |
| `AWS_ROLE_ARN_TEST` | IAM Role ARN for test environment | `arn:aws:iam::123456789:role/terraform-test` |
| `AWS_ROLE_ARN_STAGING` | IAM Role ARN for staging environment | `arn:aws:iam::123456789:role/terraform-staging` |
| `AWS_ROLE_ARN_PERF` | IAM Role ARN for perf environment | `arn:aws:iam::123456789:role/terraform-perf` |
| `AWS_ROLE_ARN_PROD` | IAM Role ARN for prod environment | `arn:aws:iam::123456789:role/terraform-prod` |
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | `https://hooks.slack.com/services/...` |
| `TF_BACKEND_KEY` | Terraform backend encryption key | *(optional)* |
| `TF_BACKEND_SECRET` | Terraform backend secret key | *(optional)* |

## Step 3: Configure GitHub Environments

Navigate to **Settings → Environments** and create:

### Environment Configuration

1. **dev**
   - No protection rules (auto-deploy)
   
2. **test**
   - Required reviewers: 1
   - Wait timer: 0 minutes
   
3. **staging**
   - Required reviewers: 1
   - Wait timer: 0 minutes
   
4. **perf**
   - Required reviewers: 1
   - Wait timer: 0 minutes
   
5. **prod**
   - Required reviewers: 2
   - Wait timer: 5 minutes
   
6. **dev-destroy**, **test-destroy**, **staging-destroy**, **perf-destroy**, **prod-destroy**
   - Required reviewers: 2 (all environments)
   - Wait timer: 15 minutes (prod)

## Step 4: Configure Branch Protection

Navigate to **Settings → Branches → Add rule**:

### Branch Protection Rules

**Branch name pattern**: `main` or `master`

✅ **Require a pull request before merging**
- Required approvals: 1 (2 for production changes)
- Dismiss stale pull request approvals when new commits are pushed
- Require review from Code Owners

✅ **Require status checks to pass before merging**
- Status checks required:
  - `Terraform Validate`
  - `Terraform Plan - Dev`
  - `Terraform Plan - Staging`
  - `Terraform Plan - Prod`

✅ **Require conversation resolution before merging**

✅ **Include administrators**

## Step 5: Configure Terraform Backend

Update your Terraform configuration to use remote state:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

Create the S3 bucket and DynamoDB table:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Step 6: Test the Pipeline

### Test PR Validation

1. Create a feature branch
2. Make a small Terraform change
3. Open a Pull Request
4. Verify that validation jobs run successfully
5. Check PR comments for plan output

### Test Deployment

1. Merge PR to main branch
2. Verify deployment workflow triggers
3. Monitor workflow execution
4. Check Slack notifications
5. Verify infrastructure changes in AWS Console

### Test Drift Detection

1. Manually trigger drift detection workflow
2. Or wait for scheduled run (daily at 2 AM UTC)
3. Verify issue creation if drift detected

## Troubleshooting

### Common Issues

#### 1. OIDC Authentication Failures

**Error**: `AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity`

**Solution**:
- Verify OIDC provider thumbprint is correct
- Check IAM role trust policy conditions
- Ensure GitHub environment name matches IAM condition

#### 2. Terraform Init Failures

**Error**: `Backend configuration changed`

**Solution**:
- Run `terraform init -reconfigure` locally first
- Update backend configuration in workflow
- Clear `.terraform` directory

#### 3. Permission Denied

**Error**: `AccessDeniedException`

**Solution**:
- Verify IAM role has sufficient permissions
- Check resource-level permissions
- Review CloudTrail logs for denied actions

#### 4. State Lock Conflicts

**Error**: `Error acquiring the state lock`

**Solution**:
- Check if another process is running
- Force unlock if safe: `terraform force-unlock <LOCK_ID>`
- Investigate stuck workflows

## Security Best Practices

1. **Never commit secrets** - Use GitHub Encrypted Secrets
2. **Use OIDC** - Avoid long-lived AWS credentials
3. **Least privilege** - Minimal IAM permissions per environment
4. **Enable MFA** - For manual workflow triggers
5. **Audit logs** - Regularly review GitHub Actions logs
6. **Rotate credentials** - Periodically rotate any static credentials
7. **Protect branches** - Enforce code review for infrastructure changes

## Monitoring and Alerts

### Key Metrics to Monitor

- Pipeline success rate
- Average deployment duration
- Drift detection frequency
- Failed deployment count

### Recommended Alerts

- Deployment failures > 3 in 24 hours
- Drift detected in production
- Pipeline duration exceeds threshold
- State lock held > 30 minutes

## Maintenance

### Regular Tasks

1. **Weekly**: Review failed workflows and fix issues
2. **Monthly**: Update Terraform version and action versions
3. **Quarterly**: Audit IAM permissions and access
4. **Annually**: Review and update security policies

### Version Updates

Keep these components updated:
- Terraform version (`TF_VERSION` in workflows)
- GitHub Actions versions (checkout, setup-terraform, etc.)
- AWS CLI version (if used)
- Security scanning tools (tfsec, checkov)

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Enterprise/Cloud](https://www.terraform.io/docs/cloud)
- [AWS IAM OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Infrastructure as Code Security Best Practices](https://owasp.org/www-project-top-10-ci-cd-security-risks/)

## Support

For issues or questions:
1. Check workflow run logs
2. Review this documentation
3. Contact infrastructure team
4. Create GitHub issue with labels: `ci-cd`, `terraform`
