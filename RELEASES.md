# Release Management

This document outlines the release management process for the S-Imperatives Infrastructure as Code project, including how to create releases, manage deployments, and perform rollbacks using GitHub pull requests.

## Overview

Our release process follows a GitOps approach where:
- All infrastructure changes are tracked through Git commits
- Releases are managed through GitHub pull requests and tags
- Rollbacks are performed by reverting to previous known-good states
- Each environment (dev, staging, prod) has its own deployment workflow

## Release Process

### 1. Development Workflow

#### Feature Development
1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes to infrastructure or Lambda functions
3. Test locally using the development environment:
   ```bash
   ./bin/all-plan.sh dev
   ```

4. Commit your changes with descriptive messages:
   ```bash
   git add .
   git commit -m "feat: add new S3 bucket policy for enhanced security"
   ```

#### Pull Request Creation
1. Push your feature branch:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Create a pull request on GitHub with:
   - Clear description of changes
   - Link to any related issues
   - Screenshots of plan outputs (if applicable)
   - Testing evidence

3. Request reviews from team members
4. Ensure all CI checks pass

### 2. Release Creation

#### Preparing for Release
1. Merge approved pull request to `main`
2. Ensure all tests pass on the main branch
3. Create a release tag:
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.0.0 -m "Release v1.0.0: Description of changes"
   git push origin v1.0.0
   ```

#### Tagging Convention
We use semantic versioning (SemVer):
- `MAJOR.MINOR.PATCH` (e.g., `v1.2.3`)
- **MAJOR**: Breaking changes to infrastructure
- **MINOR**: New features or non-breaking infrastructure changes
- **PATCH**: Bug fixes and minor updates

#### GitHub Release
1. Go to GitHub → Releases → "Create a new release"
2. Select your tag
3. Generate release notes automatically or write custom notes
4. Include:
   - Summary of changes
   - Infrastructure modifications
   - Breaking changes (if any)
   - Upgrade instructions

## Deployment Process

### Environment Promotion

#### Development Environment
- Automatically deployed on merge to `main`
- Used for integration testing
- Deploy command:
  ```bash
  ./bin/all-apply.sh dev
  ```

#### Production Environment
- Manually triggered after release creation
- Requires approval from designated team members
- Deploy command:
  ```bash
  ./bin/all-apply-prod.sh
  ```

### Deployment Verification

After each deployment, verify:

1. **Infrastructure Health**:
   ```bash
   # Check Terraform state
   cd terraform/api-gateway
   terraform show
   
   # Verify AWS resources
   aws apigateway get-rest-apis
   aws lambda list-functions
   ```

2. **API Functionality**:
   - Test all API endpoints
   - Verify authentication works
   - Check CloudWatch logs for errors

3. **Performance Metrics**:
   - Monitor response times
   - Check error rates
   - Verify scaling behavior

## Rollback Procedures

### Quick Rollback (Same Day)

If issues are detected shortly after deployment:

#### 1. Immediate Infrastructure Rollback
```bash
# Navigate to the specific module that needs rollback
cd terraform/api-gateway

# Check current state
terraform show

# Apply previous configuration (if changes were recent)
git checkout <previous-commit-hash>
terraform apply -var-file="envs/prod.hcl"

# Or use destroy/apply if major changes
terraform destroy -var-file="envs/prod.hcl"
git checkout <stable-commit>
terraform apply -var-file="envs/prod.hcl"
```

#### 2. Lambda Function Rollback
```bash
# For Lambda functions, AWS provides version control
aws lambda update-alias \
    --function-name s3-files-function \
    --name LIVE \
    --function-version <previous-version-number>
```

### Formal Rollback Process

For planned rollbacks or major issues:

#### 1. Create Rollback Pull Request

```bash
# Create rollback branch
git checkout -b rollback/v1.2.3-to-v1.2.2

# Revert to previous stable state
git revert <commit-range> # or cherry-pick stable commits

# Or reset to previous tag
git reset --hard v1.2.2

# Push rollback branch
git push origin rollback/v1.2.3-to-v1.2.2
```

#### 2. Pull Request for Rollback
Create a pull request with:
- **Title**: `Rollback: Revert to v1.2.2 due to [issue]`
- **Description**: 
  - Reason for rollback
  - Issues encountered
  - Expected behavior after rollback
  - Post-rollback verification steps

#### 3. Emergency Rollback Process
For critical production issues:

1. **Immediate Action** (authorized personnel only):
   ```bash
   # Direct rollback to last known good state
   git checkout main
   git reset --hard <last-good-commit>
   ./bin/all-apply-prod.sh
   ```

2. **Follow-up Documentation**:
   - Create incident report
   - Document what went wrong
   - Create post-mortem pull request
   - Update rollback procedures if needed

## Best Practices

### Pre-Release Checklist
- [ ] All tests passing
- [ ] Infrastructure plan reviewed
- [ ] Backup verification completed
- [ ] Rollback plan documented
- [ ] Team notification sent
- [ ] Monitoring alerts configured

### During Release
- [ ] Monitor deployment progress
- [ ] Check application health
- [ ] Verify all services responding
- [ ] Monitor error rates and performance
- [ ] Keep rollback commands ready

### Post-Release
- [ ] Verify all functionality working
- [ ] Monitor for 24 hours
- [ ] Update documentation if needed
- [ ] Close related issues/tickets
- [ ] Team notification of successful deployment

## Monitoring and Alerting

### Key Metrics to Watch
- API Gateway response times and error rates
- Lambda function duration and error rates  
- S3 operation success rates
- IAM policy violations
- CloudWatch log errors

### Alert Thresholds
- API error rate > 5%
- Lambda duration > 10 seconds
- Any IAM access denied errors
- S3 operation failures

## Emergency Contacts

In case of critical issues:
1. Check #infrastructure Slack channel
2. Contact on-call engineer via PagerDuty
3. Escalate to team lead if needed
4. Document all actions taken

## Historical Releases

| Version | Date | Description | Rollback Status |
|---------|------|-------------|-----------------|
| v1.0.0  | 2024-01-15 | Initial production release | N/A |
| v1.1.0  | 2024-02-01 | Added S3 file versioning | Tested ✅ |
| v1.2.0  | 2024-02-15 | Enhanced API Gateway security | Tested ✅ |

---

## Troubleshooting

### Common Issues and Solutions

#### Terraform State Lock
```bash
# If terraform state is locked
terraform force-unlock <lock-id>
```

#### Lambda Deployment Failures
```bash
# Check Lambda function logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/

# Get recent logs
aws logs filter-log-events --log-group-name /aws/lambda/your-function-name
```

#### API Gateway Issues
```bash
# Check API Gateway execution logs
aws logs filter-log-events --log-group-name "API-Gateway-Execution-Logs"
```

For additional support, refer to the [main README](README.md) or component-specific documentation.