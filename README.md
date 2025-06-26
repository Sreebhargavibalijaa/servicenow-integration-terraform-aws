# Automated Deployment Pipeline for ServiceNow Integration APIs using Terraform on AWS

## 🎯 Project Overview

This project demonstrates a production-ready CI/CD pipeline for deploying ServiceNow integration APIs on AWS using Terraform. It showcases enterprise-level infrastructure automation, security best practices, and DevOps principles that are highly relevant for ServiceNow roles.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│  Terraform Cloud│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudWatch    │◀───│   AWS Lambda    │◀───│  API Gateway    │
│   Monitoring    │    │   Functions     │    │   (REST API)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DynamoDB      │    │   Secrets       │    │   VPC +         │
│   (Persistence) │    │   Manager       │    │   Subnets       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Key Features

- **Infrastructure as Code**: Complete AWS infrastructure defined in Terraform
- **CI/CD Pipeline**: Automated deployment via GitHub Actions
- **Security**: IAM roles with least privilege, secrets management
- **Monitoring**: CloudWatch logs, metrics, and alerts
- **Scalability**: Serverless architecture with Lambda and API Gateway
- **ServiceNow Integration**: Ready-to-use API endpoints for ServiceNow operations

## 📁 Project Structure

```
TERRFORM-CI/
├── terraform/                    # Terraform configuration
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── vpc/                 # VPC and networking
│   │   ├── lambda/              # Lambda functions
│   │   ├── api-gateway/         # API Gateway configuration
│   │   ├── dynamodb/            # DynamoDB tables
│   │   ├── monitoring/          # CloudWatch monitoring
│   │   └── iam/                 # IAM roles and policies
│   ├── environments/            # Environment-specific configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── main.tf                  # Root Terraform configuration
├── src/                         # Application source code
│   ├── lambda/                  # Lambda function code
│   │   ├── servicenow-api/      # ServiceNow API integration
│   │   └── utils/               # Utility functions
│   └── api/                     # API definitions
├── .github/                     # GitHub Actions workflows
│   └── workflows/
├── scripts/                     # Deployment and utility scripts
├── docs/                        # Documentation
└── tests/                       # Infrastructure and unit tests
```

## 🛠️ Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform CLI (v1.0+)
- GitHub account with repository access
- Terraform Cloud account (for remote state management)
- ServiceNow instance with API access

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd TERRFORM-CI
```

### 2. Configure Environment Variables

```bash
# Copy and configure environment variables
cp .env.example .env
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

### 5. Configure GitHub Actions

1. Add repository secrets in GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `TF_API_TOKEN` (Terraform Cloud)
   - `SERVICENOW_INSTANCE_URL`
   - `SERVICENOW_CLIENT_ID`
   - `SERVICENOW_CLIENT_SECRET`

2. Push code to trigger the CI/CD pipeline

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `AWS_REGION` | AWS region for deployment | Yes |
| `SERVICENOW_INSTANCE_URL` | ServiceNow instance URL | Yes |
| `SERVICENOW_CLIENT_ID` | ServiceNow OAuth client ID | Yes |
| `SERVICENOW_CLIENT_SECRET` | ServiceNow OAuth client secret | Yes |

### Terraform Variables

See `terraform/variables.tf` for all configurable variables.

## 📊 Monitoring and Logging

- **CloudWatch Logs**: All Lambda function logs
- **CloudWatch Metrics**: API Gateway metrics, Lambda performance
- **CloudWatch Alarms**: Error rate, latency, and availability monitoring
- **X-Ray Tracing**: Distributed tracing for API calls

## 🔒 Security Features

- **IAM Roles**: Least privilege access for all services
- **Secrets Manager**: Secure storage of API keys and tokens
- **VPC**: Private subnets for Lambda functions
- **API Gateway**: Request validation and rate limiting
- **CloudTrail**: API call logging and auditing

## 🧪 Testing

```bash
# Run infrastructure tests
cd tests
terraform test

# Run unit tests
npm test

# Run integration tests
npm run test:integration
```

## 📈 Scaling and Performance

- **Auto-scaling**: Lambda functions scale automatically
- **API Gateway**: Built-in throttling and caching
- **DynamoDB**: On-demand capacity for unpredictable workloads
- **CloudFront**: Global content delivery (optional)

## 🚨 Troubleshooting

### Common Issues

1. **Terraform State Lock**: Check Terraform Cloud for locked states
2. **IAM Permissions**: Verify AWS credentials have required permissions
3. **ServiceNow API Limits**: Monitor API rate limits and quotas
4. **Lambda Timeout**: Adjust timeout settings for long-running operations

### Debug Commands

```bash
# Check Terraform state
terraform state list

# View CloudWatch logs
aws logs describe-log-groups

# Test API endpoints
curl -X GET https://your-api-gateway-url/health
```

## 📚 API Documentation

### Available Endpoints

- `GET /health` - Health check endpoint
- `POST /incidents` - Create ServiceNow incident
- `GET /incidents/{id}` - Get incident details
- `PUT /incidents/{id}` - Update incident
- `GET /users` - List ServiceNow users
- `POST /changes` - Create change request

### Example Usage

```bash
# Create an incident
curl -X POST https://your-api-gateway-url/incidents \
  -H "Content-Type: application/json" \
  -d '{
    "short_description": "API Test Incident",
    "description": "This is a test incident created via API",
    "priority": "3"
  }'
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the [documentation](docs/)
- Review the [troubleshooting guide](docs/troubleshooting.md)

---

**Built with ❤️ for ServiceNow professionals who love infrastructure automation** 