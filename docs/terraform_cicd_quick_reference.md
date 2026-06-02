# Terraform CI/CD Quick Reference

##  Quick Start Checklist

### 1. AWS Setup (One-time)

```bash
# Create OIDC Provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e38db1e8f

# Create IAM Roles for each environment
./scripts/create-iam-roles.sh  # See IAM_POLICY_TEMPLATES.md
```

### 2. GitHub Configuration

**Add Secrets** (Settings → Secrets and variables → Actions):
```
AWS_ROLE_ARN_DEV=arn:aws:iam::ACCOUNT_ID:role/terraform-dev
AWS_ROLE_ARN_TEST=arn:aws:iam::ACCOUNT_ID:role/terraform-test
AWS_ROLE_ARN_STAGING=arn:aws:iam::ACCOUNT_ID:role/terraform-staging
AWS_ROLE_ARN_PERF=arn:aws:iam::ACCOUNT_ID:role/terraform-perf
AWS_ROLE_ARN_PROD=arn:aws:iam::ACCOUNT_ID:role/terraform-prod
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK
```

**Create Environments** (Settings → Environments):
- `dev` - No protection
- `test` - 1 reviewer
- `staging` - 1 reviewer
- `perf` - 1 reviewer  
- `prod` - 2 reviewers, 5min wait
- `<env>-destroy` - 2 reviewers all

**Branch Protection** (Settings → Branches):
- Require PR reviews
- Require status checks
- Require Code Owners

### 3. Test Pipeline

```bash
# Create test branch
git checkout -b test-cicd

# Make small Terraform change
echo '# Test' >> tf/test.tf

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin test-cicd

# Open PR and verify workflows run
```

##  Workflow Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `terraform-pr.yml` | PR to main | Validate & plan |
| `terraform-apply.yml` | Merge to main / Manual | Deploy infrastructure |
| `terraform-destroy.yml` | Manual only | Destroy infrastructure |
| `terraform-drift-detect.yml` | Daily 2AM UTC / Manual | Detect configuration drift |

##  Common Commands

### Local Testing

```bash
# Format check
cd tf && terraform fmt -check -recursive

# Validate
cd tf && terraform validate

# Plan for specific environment
cd tf && terraform plan -var-file="envs/terraform_dev.tfvars"

# Apply (careful!)
cd tf && terraform apply -var-file="envs/terraform_dev.tfvars"
```

### Manual Workflow Dispatch

```bash
# Via GitHub UI:
# 1. Go to Actions tab
# 2. Select workflow
# 3. Click "Run workflow"
# 4. Select environment
# 5. Confirm and run
```

##  Troubleshooting

### OIDC Authentication Failed

**Symptom**: `AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity`

**Fix**:
1. Verify OIDC provider exists: `aws iam list-open-id-connect-providers`
2. Check role trust policy matches your repo
3. Ensure GitHub environment name matches IAM condition
4. Verify secret ARN is correct

### Terraform Init Failed

**Symptom**: `Backend configuration changed`

**Fix**:
```bash
cd tf
rm -rf .terraform
terraform init -reconfigure
```

### Permission Denied

**Symptom**: `AccessDeniedException` on AWS API calls

**Fix**:
1. Check IAM role has required permissions
2. Review CloudTrail logs for denied actions
3. Verify resource-level permissions
4. Test with broader permissions in dev first

### State Lock Issues

**Symptom**: `Error acquiring the state lock`

**Fix**:
```bash
# Check for running processes
terraform force-unlock <LOCK_ID>

# If stuck, investigate workflow runs
# Cancel any stuck workflows in GitHub Actions
```

##  File Structure

```
.github/
├── CODEOWNERS                          # Code review assignments
└── workflows/
    ├── README.md                       # This documentation
    ├── terraform-pr.yml               # PR validation
    ├── terraform-apply.yml            # Deployment
    ├── terraform-destroy.yml          # Controlled destruction
    └── terraform-drift-detect.yml     # Drift monitoring

docs/
├── TERRAFORM_CICD_DESIGN.md           # Architecture design
├── TERRAFORM_CICD_SETUP.md            # Complete setup guide
├── IAM_POLICY_TEMPLATES.md            # IAM policy examples
└── TERRAFORM_CICD_QUICK_REFERENCE.md  # This file

tf/
├── backend-config.example.tf.sample          # Backend configuration template
└── envs/
    ├── terraform_dev.tfvars
    ├── terraform_staging.tfvars
    ├── terraform_perf.tfvars
    └── terraform_prod.tfvars
```

## 🔒 Security Checklist

- [ ] OIDC configured (no long-lived credentials)
- [ ] Environment-specific IAM roles
- [ ] Least privilege permissions
- [ ] Branch protection enabled
- [ ] Required reviewers configured
- [ ] CODEOWNERS file updated
- [ ] Slack notifications working
- [ ] State encryption enabled
- [ ] State locking configured
- [ ] MFA required for manual operations

## 📞 Support Resources

- **Documentation**: `/docs` directory
- **Workflow Logs**: GitHub Actions tab
- **Issues**: Create with labels `ci-cd`, `terraform`
- **Team**: @infrastructure-team, @devops-team

## 🎯 Best Practices

1. **Always create PRs** - Never push directly to main
2. **Review plans** - Check PR comments before merging
3. **Test in dev first** - Validate changes in dev environment
4. **Monitor deployments** - Watch workflow runs and Slack alerts
5. **Address drift quickly** - Fix configuration drift when detected
6. **Keep secrets secure** - Never commit sensitive data
7. **Document changes** - Update docs when making significant changes
8. **Regular audits** - Review permissions and access quarterly

---

For detailed setup instructions, see [TERRAFORM_CICD_SETUP.md](TERRAFORM_CICD_SETUP.md)
