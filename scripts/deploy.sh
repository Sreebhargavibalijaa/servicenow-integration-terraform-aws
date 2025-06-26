#!/bin/bash

# ServiceNow Integration Terraform Deployment Script
# This script automates the deployment of the ServiceNow integration infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate prerequisites
validate_prerequisites() {
    print_status "Validating prerequisites..."
    
    # Check if Terraform is installed
    if ! command_exists terraform; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command_exists aws; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Check if jq is installed (for JSON parsing)
    if ! command_exists jq; then
        print_warning "jq is not installed. Some features may not work properly."
    fi
    
    print_success "Prerequisites validation completed"
}

# Function to parse command line arguments
parse_arguments() {
    ENVIRONMENT=""
    ACTION=""
    AUTO_APPROVE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -a|--action)
                ACTION="$2"
                shift 2
                ;;
            --auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$ENVIRONMENT" ]]; then
        print_error "Environment is required. Use -e or --environment"
        show_help
        exit 1
    fi
    
    if [[ -z "$ACTION" ]]; then
        print_error "Action is required. Use -a or --action"
        show_help
        exit 1
    fi
    
    # Validate environment
    if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "prod" ]]; then
        print_error "Invalid environment. Must be dev, staging, or prod"
        exit 1
    fi
    
    # Validate action
    if [[ "$ACTION" != "plan" && "$ACTION" != "apply" && "$ACTION" != "destroy" && "$ACTION" != "validate" ]]; then
        print_error "Invalid action. Must be plan, apply, destroy, or validate"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 -e ENVIRONMENT -a ACTION [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENVIRONMENT  Environment to deploy (dev, staging, prod)"
    echo "  -a, --action ACTION            Action to perform (plan, apply, destroy, validate)"
    echo "  --auto-approve                 Skip interactive approval for apply/destroy"
    echo "  -h, --help                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -a plan"
    echo "  $0 -e prod -a apply --auto-approve"
    echo "  $0 -e dev -a destroy"
}

# Function to set up environment
setup_environment() {
    print_status "Setting up environment: $ENVIRONMENT"
    
    # Change to terraform directory
    cd terraform
    
    # Copy environment-specific variables
    if [[ -f "environments/$ENVIRONMENT/terraform.tfvars" ]]; then
        cp "environments/$ENVIRONMENT/terraform.tfvars" .
        print_success "Copied environment configuration"
    else
        print_error "Environment configuration file not found: environments/$ENVIRONMENT/terraform.tfvars"
        exit 1
    fi
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Function to validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    
    # Format check
    if ! terraform fmt -check -recursive .; then
        print_error "Terraform files are not properly formatted. Run 'terraform fmt' to fix."
        exit 1
    fi
    
    # Validate configuration
    if ! terraform validate; then
        print_error "Terraform configuration validation failed"
        exit 1
    fi
    
    print_success "Terraform configuration validation completed"
}

# Function to run Terraform plan
run_plan() {
    print_status "Running Terraform plan..."
    
    # Create plan file
    terraform plan -out=tfplan
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform plan completed successfully"
        
        # Show plan summary
        print_status "Plan summary:"
        terraform show tfplan | grep -E "(Plan:| \+ | \- | ~ )" | head -20
        
        # Ask for confirmation if not auto-approve
        if [[ "$AUTO_APPROVE" == false ]]; then
            echo ""
            read -p "Do you want to apply this plan? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_warning "Plan application cancelled"
                exit 0
            fi
        fi
    else
        print_error "Terraform plan failed"
        exit 1
    fi
}

# Function to run Terraform apply
run_apply() {
    print_status "Running Terraform apply..."
    
    if [[ -f "tfplan" ]]; then
        terraform apply tfplan
    else
        if [[ "$AUTO_APPROVE" == true ]]; then
            terraform apply -auto-approve
        else
            terraform apply
        fi
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform apply completed successfully"
        
        # Show outputs
        print_status "Deployment outputs:"
        terraform output
        
        # Get API Gateway URL
        API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "Not available")
        if [[ "$API_URL" != "Not available" ]]; then
            print_success "API Gateway URL: $API_URL"
        fi
    else
        print_error "Terraform apply failed"
        exit 1
    fi
}

# Function to run Terraform destroy
run_destroy() {
    print_status "Running Terraform destroy..."
    
    # Show warning for production
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        print_warning "You are about to destroy PRODUCTION infrastructure!"
        echo ""
        read -p "Are you absolutely sure? Type 'yes' to confirm: " -r
        if [[ "$REPLY" != "yes" ]]; then
            print_warning "Destroy cancelled"
            exit 0
        fi
    fi
    
    if [[ "$AUTO_APPROVE" == true ]]; then
        terraform destroy -auto-approve
    else
        terraform destroy
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform destroy completed successfully"
    else
        print_error "Terraform destroy failed"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    print_status "Running post-deployment tests..."
    
    # Get API Gateway URL
    API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")
    
    if [[ -n "$API_URL" ]]; then
        # Test health endpoint
        print_status "Testing health endpoint..."
        if curl -f -s "$API_URL/health" >/dev/null; then
            print_success "Health endpoint test passed"
        else
            print_error "Health endpoint test failed"
            return 1
        fi
        
        # Test incidents endpoint
        print_status "Testing incidents endpoint..."
        if curl -f -s "$API_URL/incidents" >/dev/null; then
            print_success "Incidents endpoint test passed"
        else
            print_error "Incidents endpoint test failed"
            return 1
        fi
    else
        print_warning "API Gateway URL not available, skipping tests"
    fi
    
    print_success "Post-deployment tests completed"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    
    # Remove temporary files
    rm -f tfplan
    rm -f terraform.tfvars
    
    print_success "Cleanup completed"
}

# Main function
main() {
    print_status "Starting ServiceNow Integration deployment..."
    print_status "Environment: $ENVIRONMENT"
    print_status "Action: $ACTION"
    
    # Validate prerequisites
    validate_prerequisites
    
    # Setup environment
    setup_environment
    
    # Validate Terraform configuration
    validate_terraform
    
    # Execute action
    case "$ACTION" in
        "plan")
            run_plan
            ;;
        "apply")
            run_apply
            run_tests
            ;;
        "destroy")
            run_destroy
            ;;
        "validate")
            print_success "Validation completed"
            ;;
    esac
    
    # Cleanup
    cleanup
    
    print_success "Deployment script completed successfully"
}

# Parse arguments and run main function
parse_arguments "$@"
main 