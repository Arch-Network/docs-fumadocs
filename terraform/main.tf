terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "fumadocs/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Fumadocs"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# IAM role for Amplify
resource "aws_iam_role" "amplify_role" {
  name = "${var.app_name}-amplify-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach basic Amplify execution policy
resource "aws_iam_role_policy" "amplify_policy" {
  name = "${var.app_name}-amplify-policy-${var.environment}"
  role = aws_iam_role.amplify_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Amplify App
resource "aws_amplify_app" "fumadocs" {
  name       = var.app_name
  repository = var.github_repository

  # GitHub access token (store in AWS Secrets Manager or pass as variable)
  access_token = var.github_access_token

  # Build settings for Next.js
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
            - npm run postinstall
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
          - .next/cache/**/*
  EOT

  # Environment variables for the build
  environment_variables = merge(
    {
      NEXT_PUBLIC_SITE_URL = var.site_url
      NODE_ENV             = "production"
      # Add any other environment variables your app needs
    },
    var.additional_environment_variables
  )

  # Enable auto branch creation for feature branches (optional)
  enable_auto_branch_creation = var.enable_auto_branch_creation
  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  auto_branch_creation_config {
    enable_auto_build = true
    framework         = "Next.js - SSR"
    stage             = "DEVELOPMENT"
  }

  # Platform settings
  platform = "WEB_COMPUTE"

  # Enable branch auto-deletion
  enable_branch_auto_deletion = true

  # Note: No custom SPA rewrites. Amplify WEB_COMPUTE handles Next.js SSR routing.

  iam_service_role_arn = aws_iam_role.amplify_role.arn

  tags = {
    Name = var.app_name
  }
}

# Main branch deployment
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.fumadocs.id
  branch_name = var.main_branch_name

  framework = "Next.js - SSR"
  stage     = var.environment == "production" ? "PRODUCTION" : "DEVELOPMENT"

  enable_auto_build = true

  # Environment variables specific to this branch (if needed)
  environment_variables = var.branch_environment_variables

  tags = {
    Name        = "${var.app_name}-${var.main_branch_name}"
    Branch      = var.main_branch_name
  }
}

# Custom domain (optional)
resource "aws_amplify_domain_association" "main" {
  count = var.custom_domain != "" ? 1 : 0

  app_id      = aws_amplify_app.fumadocs.id
  domain_name = var.custom_domain

  # Subdomain settings
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = var.domain_prefix
  }

  # Wait for DNS propagation
  wait_for_verification = true
}
