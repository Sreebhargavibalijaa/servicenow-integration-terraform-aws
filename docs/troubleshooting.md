# Troubleshooting Guide

This guide provides solutions for common issues encountered when deploying and operating the ServiceNow Integration API.

## Table of Contents

1. [Prerequisites Issues](#prerequisites-issues)
2. [Terraform Deployment Issues](#terraform-deployment-issues)
3. [Lambda Function Issues](#lambda-function-issues)
4. [API Gateway Issues](#api-gateway-issues)
5. [DynamoDB Issues](#dynamodb-issues)
6. [ServiceNow Integration Issues](#servicenow-integration-issues)
7. [Monitoring and Logging Issues](#monitoring-and-logging-issues)
8. [Security Issues](#security-issues)
9. [Performance Issues](#performance-issues)
10. [CI/CD Pipeline Issues](#cicd-pipeline-issues)

## Prerequisites Issues

### Issue: Terraform not installed or wrong version

**Symptoms**: `terraform: command not found` or version compatibility errors

**Solution**:
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs)"
sudo apt-get update && sudo apt-get install terraform

# Verify version
terraform version
```

### Issue: AWS credentials not configured

**Symptoms**: `NoCredentialsError: Unable to locate credentials`

**Solution**:
```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify configuration
aws sts get-caller-identity
```

### Issue: Insufficient AWS permissions

**Symptoms**: `AccessDenied` errors during deployment

**Solution**:
Ensure your AWS user/role has the following permissions:
- IAM (create roles and policies)
- VPC (create VPC, subnets, security groups)
- Lambda (create and manage functions)
- API Gateway (create and manage APIs)
- DynamoDB (create and manage tables)
- CloudWatch (create log groups and alarms)
- Secrets Manager (create and manage secrets)

## Terraform Deployment Issues

### Issue: Terraform state lock

**Symptoms**: `Error acquiring the state lock`

**Solution**:
```bash
# Check for locks in Terraform Cloud
# Or force unlock (use with caution)
terraform force-unlock <lock-id>

# If using local state, check for .terraform.tfstate.lock.info
rm .terraform.tfstate.lock.info
```

### Issue: Module not found

**Symptoms**: `Module not found` errors

**Solution**:
```bash
# Reinitialize Terraform
terraform init

# Check module paths in main.tf
# Ensure all module directories exist
ls -la terraform/modules/
```

### Issue: Variable validation errors

**Symptoms**: `Invalid value for variable` errors

**Solution**:
```bash
# Check variable definitions in variables.tf
# Verify terraform.tfvars file
cat terraform/terraform.tfvars

# Use terraform validate to check configuration
terraform validate
```

### Issue: Resource creation timeout

**Symptoms**: `timeout while waiting for state to become` errors

**Solution**:
```bash
# Increase timeout values in variables.tf
# Check AWS service limits
# Verify network connectivity
# Retry deployment
terraform apply
```

## Lambda Function Issues

### Issue: Lambda function not found

**Symptoms**: `Function not found` errors

**Solution**:
```bash
# Check if function exists
aws lambda list-functions --region us-east-1

# Verify function name in Terraform output
terraform output lambda_functions

# Redeploy if function is missing
terraform apply
```

### Issue: Lambda execution role permissions

**Symptoms**: `AccessDenied` errors in Lambda logs

**Solution**:
```bash
# Check IAM role permissions
aws iam get-role --role-name <role-name>

# Verify role policies
aws iam list-attached-role-policies --role-name <role-name>

# Update role if needed
terraform apply
```

### Issue: Lambda timeout

**Symptoms**: `Task timed out` errors

**Solution**:
```bash
# Increase timeout in variables.tf
lambda_timeout = 60

# Check ServiceNow API response times
# Optimize Lambda function code
# Consider using async processing
```

### Issue: Lambda memory issues

**Symptoms**: `Memory limit exceeded` errors

**Solution**:
```bash
# Increase memory allocation
lambda_memory_size = 1024

# Optimize code to reduce memory usage
# Check for memory leaks
# Monitor memory usage in CloudWatch
```

### Issue: VPC connectivity issues

**Symptoms**: `ENI limit exceeded` or network timeout errors

**Solution**:
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids <vpc-id>

# Verify subnet configuration
aws ec2 describe-subnets --subnet-ids <subnet-id>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Increase ENI limits if needed
```

## API Gateway Issues

### Issue: API Gateway not accessible

**Symptoms**: Connection timeout or 403 errors

**Solution**:
```bash
# Check API Gateway URL
terraform output api_gateway_url

# Verify API Gateway deployment
aws apigateway get-rest-api --rest-api-id <api-id>

# Check stage deployment
aws apigateway get-stage --rest-api-id <api-id> --stage-name dev

# Redeploy if needed
terraform apply
```

### Issue: CORS errors

**Symptoms**: `CORS policy` errors in browser

**Solution**:
```bash
# Check CORS configuration in Lambda function
# Verify Access-Control-Allow-Origin headers
# Test with curl to isolate CORS issues
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS <api-url>/health
```

### Issue: API Gateway throttling

**Symptoms**: `Too Many Requests` errors

**Solution**:
```bash
# Check throttling settings
aws apigateway get-usage-plan --usage-plan-id <plan-id>

# Increase throttling limits
# Implement client-side retry logic
# Consider using API Gateway caching
```

## DynamoDB Issues

### Issue: DynamoDB table not found

**Symptoms**: `Table not found` errors

**Solution**:
```bash
# Check if table exists
aws dynamodb describe-table --table-name <table-name>

# Verify table creation in Terraform
terraform output dynamodb_tables

# Check table status
aws dynamodb describe-table --table-name <table-name> --query 'Table.TableStatus'
```

### Issue: DynamoDB throttling

**Symptoms**: `ProvisionedThroughputExceededException` errors

**Solution**:
```bash
# Check table capacity
aws dynamodb describe-table --table-name <table-name>

# Switch to on-demand billing
# Implement exponential backoff
# Optimize query patterns
# Use DynamoDB Streams for high-volume writes
```

### Issue: DynamoDB permission errors

**Symptoms**: `AccessDenied` errors

**Solution**:
```bash
# Check IAM permissions
aws iam get-role-policy --role-name <role-name> --policy-name <policy-name>

# Verify DynamoDB table ARN in policy
# Update IAM policy if needed
terraform apply
```

## ServiceNow Integration Issues

### Issue: ServiceNow authentication failed

**Symptoms**: `401 Unauthorized` errors

**Solution**:
```bash
# Check credentials in Secrets Manager
aws secretsmanager get-secret-value --secret-id <secret-name>

# Verify ServiceNow instance URL
# Check username/password validity
# Test credentials manually
curl -u username:password https://instance.service-now.com/api/now/table/incident
```

### Issue: ServiceNow API rate limiting

**Symptoms**: `429 Too Many Requests` errors

**Solution**:
```bash
# Implement exponential backoff
# Add request throttling
# Use ServiceNow bulk API endpoints
# Monitor API usage in ServiceNow
```

### Issue: ServiceNow API timeout

**Symptoms**: `Request timeout` errors

**Solution**:
```bash
# Increase Lambda timeout
# Implement retry logic
# Check ServiceNow instance performance
# Use async processing for long-running operations
```

### Issue: ServiceNow data format issues

**Symptoms**: `Invalid JSON` or parsing errors

**Solution**:
```bash
# Check ServiceNow API response format
# Verify data transformation logic
# Add input validation
# Test with sample data
```

## Monitoring and Logging Issues

### Issue: CloudWatch logs not appearing

**Symptoms**: No logs in CloudWatch

**Solution**:
```bash
# Check log group exists
aws logs describe-log-groups --log-group-name-prefix <prefix>

# Verify Lambda function logging
# Check IAM permissions for CloudWatch
# Test logging manually
```

### Issue: CloudWatch alarms not triggering

**Symptoms**: Alarms not firing when expected

**Solution**:
```bash
# Check alarm configuration
aws cloudwatch describe-alarms --alarm-names <alarm-name>

# Verify metric data
aws cloudwatch get-metric-statistics --namespace AWS/Lambda --metric-name Errors

# Check alarm thresholds
# Verify alarm actions (SNS topics)
```

### Issue: SNS notifications not working

**Symptoms**: No email/Slack notifications

**Solution**:
```bash
# Check SNS topic exists
aws sns list-topics

# Verify topic subscriptions
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>

# Test SNS manually
aws sns publish --topic-arn <topic-arn> --message "Test message"
```

## Security Issues

### Issue: Secrets Manager access denied

**Symptoms**: `AccessDenied` when accessing secrets

**Solution**:
```bash
# Check IAM permissions for Secrets Manager
aws iam get-role-policy --role-name <role-name> --policy-name <policy-name>

# Verify secret ARN in policy
# Check secret rotation status
aws secretsmanager describe-secret --secret-id <secret-name>
```

### Issue: VPC security group issues

**Symptoms**: Network connectivity problems

**Solution**:
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Verify inbound/outbound rules
# Check VPC routing
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"
```

### Issue: IAM role trust policy issues

**Symptoms**: `AssumeRole` errors

**Solution**:
```bash
# Check role trust policy
aws iam get-role --role-name <role-name>

# Verify service principals
# Check external ID if using cross-account access
# Update trust policy if needed
```

## Performance Issues

### Issue: High Lambda cold start times

**Symptoms**: Slow initial response times

**Solution**:
```bash
# Use provisioned concurrency
# Optimize Lambda package size
# Use Lambda layers for dependencies
# Implement connection pooling
```

### Issue: DynamoDB slow queries

**Symptoms**: High read/write latency

**Solution**:
```bash
# Check table indexes
aws dynamodb describe-table --table-name <table-name>

# Optimize query patterns
# Use Global Secondary Indexes
# Implement caching
# Monitor consumed capacity
```

### Issue: API Gateway latency

**Symptoms**: High response times

**Solution**:
```bash
# Enable API Gateway caching
# Use CloudFront for global distribution
# Optimize Lambda function performance
# Monitor API Gateway metrics
```

## CI/CD Pipeline Issues

### Issue: GitHub Actions workflow failures

**Symptoms**: Pipeline failing at various stages

**Solution**:
```bash
# Check workflow logs in GitHub
# Verify GitHub secrets are configured
# Test workflow locally
# Check AWS credentials in GitHub
```

### Issue: Terraform Cloud workspace issues

**Symptoms**: Remote state errors

**Solution**:
```bash
# Check Terraform Cloud workspace
# Verify API token
# Check workspace variables
# Reinitialize Terraform
terraform init
```

### Issue: Build failures

**Symptoms**: Lambda package creation fails

**Solution**:
```bash
# Check Node.js dependencies
npm install

# Verify package.json files
# Check file permissions
# Test build locally
```

## Debugging Commands

### General Debugging

```bash
# Check Terraform state
terraform state list
terraform show

# Check AWS resources
aws sts get-caller-identity
aws ec2 describe-regions

# Check Lambda functions
aws lambda list-functions --region us-east-1

# Check API Gateway
aws apigateway get-rest-apis

# Check DynamoDB tables
aws dynamodb list-tables

# Check CloudWatch logs
aws logs describe-log-groups
```

### Network Debugging

```bash
# Check VPC configuration
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-security-groups

# Test connectivity
telnet <host> <port>
curl -v <url>
```

### Security Debugging

```bash
# Check IAM roles
aws iam get-role --role-name <role-name>
aws iam list-attached-role-policies --role-name <role-name>

# Check secrets
aws secretsmanager list-secrets
aws secretsmanager describe-secret --secret-id <secret-name>
```

## Getting Help

### Internal Resources

1. **Project Documentation**: Check the `docs/` directory
2. **Code Comments**: Review inline documentation
3. **Git History**: Check recent changes and commits
4. **Team Knowledge**: Consult with team members

### External Resources

1. **AWS Documentation**: [aws.amazon.com/documentation](https://aws.amazon.com/documentation/)
2. **Terraform Documentation**: [terraform.io/docs](https://www.terraform.io/docs)
3. **ServiceNow Documentation**: [docs.servicenow.com](https://docs.servicenow.com)
4. **GitHub Issues**: Check for similar issues in the repository

### Support Channels

1. **AWS Support**: If you have AWS support plan
2. **ServiceNow Support**: For ServiceNow-specific issues
3. **Community Forums**: Stack Overflow, Reddit, etc.
4. **Professional Services**: For complex enterprise issues

## Prevention Best Practices

1. **Regular Monitoring**: Set up comprehensive monitoring
2. **Automated Testing**: Implement automated tests
3. **Documentation**: Keep documentation up to date
4. **Backup Strategy**: Regular backups and disaster recovery testing
5. **Security Reviews**: Regular security assessments
6. **Performance Monitoring**: Continuous performance optimization
7. **Change Management**: Proper change control procedures
8. **Training**: Regular team training on new features 