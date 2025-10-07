#!/bin/bash

# Terraform AWS Amplify Setup Script
# This script helps you set up and deploy the Fumadocs site to AWS Amplify

set -e

echo "🚀 AWS Amplify Terraform Setup"
echo "==============================="
echo ""

# Check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed. Install it with:"
        echo "   brew install terraform"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI is not installed. Install it with:"
        echo "   brew install awscli"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS credentials not configured. Run:"
        echo "   aws configure"
        exit 1
    fi
    
    echo "✅ All prerequisites met!"
    echo ""
}

# Create terraform.tfvars if it doesn't exist
create_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        echo "📝 Creating terraform.tfvars..."
        echo ""
        
        read -p "Enter your GitHub repository URL (e.g., https://github.com/username/repo): " github_repo
        read -p "Enter your GitHub personal access token: " -s github_token
        echo ""
        read -p "Enter your site URL (e.g., https://docs.arch.network): " site_url
        read -p "Enter custom domain (leave empty to skip): " custom_domain
        
        cat > terraform.tfvars <<EOF
# Terraform Variables
aws_region         = "us-east-1"
environment        = "production"
app_name           = "arch-network-docs"
main_branch_name   = "main"

# GitHub Configuration
github_repository    = "${github_repo}"
github_access_token  = "${github_token}"

# Site Configuration
site_url = "${site_url}"

# Custom Domain
custom_domain = "${custom_domain}"
domain_prefix = ""

# Auto Branch Creation
enable_auto_branch_creation   = false
auto_branch_creation_patterns = ["feature/*", "fix/*"]
EOF
        
        echo "✅ terraform.tfvars created!"
        echo ""
    else
        echo "✅ terraform.tfvars already exists"
        echo ""
    fi
}

# Initialize Terraform
init_terraform() {
    echo "🔧 Initializing Terraform..."
    terraform init
    echo ""
}

# Plan deployment
plan_deployment() {
    echo "📊 Planning deployment..."
    echo ""
    terraform plan
    echo ""
}

# Apply deployment
apply_deployment() {
    echo "🚢 Deploying to AWS Amplify..."
    echo ""
    terraform apply
    echo ""
}

# Show outputs
show_outputs() {
    echo "🎉 Deployment complete!"
    echo ""
    echo "📍 Deployment URLs:"
    terraform output
    echo ""
    echo "Next steps:"
    echo "1. Visit the Amplify console: https://console.aws.amazon.com/amplify"
    echo "2. Monitor your build progress"
    echo "3. If using a custom domain, add DNS records shown in Amplify console"
    echo ""
}

# Main menu
main_menu() {
    echo "What would you like to do?"
    echo "1) Full setup (check prereqs, create config, deploy)"
    echo "2) Just initialize Terraform"
    echo "3) Plan deployment (preview changes)"
    echo "4) Deploy to AWS"
    echo "5) Show deployment info"
    echo "6) Destroy infrastructure"
    echo "0) Exit"
    echo ""
    read -p "Select an option: " option
    
    case $option in
        1)
            check_prerequisites
            create_tfvars
            init_terraform
            plan_deployment
            read -p "Do you want to proceed with deployment? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                apply_deployment
                show_outputs
            fi
            ;;
        2)
            init_terraform
            ;;
        3)
            plan_deployment
            ;;
        4)
            apply_deployment
            show_outputs
            ;;
        5)
            terraform output
            ;;
        6)
            echo "⚠️  WARNING: This will destroy all infrastructure!"
            read -p "Are you sure? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                terraform destroy
            fi
            ;;
        0)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Run main menu
main_menu
