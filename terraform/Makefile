.PHONY: help init plan apply destroy output validate format clean setup

# Default target
help:
	@echo "AWS Amplify Terraform Commands"
	@echo "==============================="
	@echo ""
	@echo "Setup & Configuration:"
	@echo "  make setup      - Interactive setup wizard"
	@echo "  make init       - Initialize Terraform"
	@echo "  make validate   - Validate configuration"
	@echo ""
	@echo "Deployment:"
	@echo "  make plan       - Preview infrastructure changes"
	@echo "  make apply      - Deploy to AWS"
	@echo "  make output     - Show deployment URLs"
	@echo ""
	@echo "Maintenance:"
	@echo "  make format     - Format Terraform files"
	@echo "  make destroy    - Destroy all infrastructure (careful!)"
	@echo "  make clean      - Clean local Terraform files"
	@echo ""

# Interactive setup
setup:
	@./setup.sh

# Initialize Terraform
init:
	@echo "🔧 Initializing Terraform..."
	@terraform init

# Validate configuration
validate: init
	@echo "✓ Validating configuration..."
	@terraform validate

# Format Terraform files
format:
	@echo "📝 Formatting Terraform files..."
	@terraform fmt -recursive

# Preview changes
plan: validate
	@echo "📊 Planning deployment..."
	@terraform plan

# Deploy to AWS
apply: validate
	@echo "🚢 Deploying to AWS Amplify..."
	@terraform apply

# Quick deploy (auto-approve)
deploy: validate
	@echo "🚢 Deploying to AWS Amplify (auto-approve)..."
	@terraform apply -auto-approve

# Show outputs
output:
	@echo "📍 Deployment Information:"
	@terraform output

# Destroy infrastructure
destroy:
	@echo "⚠️  WARNING: This will destroy all infrastructure!"
	@terraform destroy

# Clean local files
clean:
	@echo "🧹 Cleaning local Terraform files..."
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@rm -f terraform.tfstate
	@rm -f terraform.tfstate.backup
	@rm -f crash.log
	@echo "✓ Cleaned!"

# Check AWS credentials
check-aws:
	@echo "🔐 Checking AWS credentials..."
	@aws sts get-caller-identity || (echo "❌ AWS credentials not configured. Run: aws configure" && exit 1)
	@echo "✓ AWS credentials OK!"

# Full deployment workflow
deploy-full: check-aws validate plan
	@echo ""
	@read -p "Deploy to AWS? (yes/no): " confirm && [ "$$confirm" = "yes" ] && make apply || echo "Cancelled"
