variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Name of the Amplify application"
  type        = string
  default     = "arch-network-docs"
}

variable "github_repository" {
  description = "GitHub repository URL (e.g., https://github.com/username/repo)"
  type        = string
  # Set this via terraform.tfvars or environment variable
}

variable "github_access_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
  # Set this via terraform.tfvars or environment variable
  # Never commit this to version control!
}

variable "main_branch_name" {
  description = "Name of the main branch to deploy"
  type        = string
  default     = "main"
}

variable "site_url" {
  description = "Public URL of the site"
  type        = string
  default     = ""
}

variable "custom_domain" {
  description = "Custom domain for the application (leave empty to skip)"
  type        = string
  default     = ""
}

variable "domain_prefix" {
  description = "Subdomain prefix (e.g., 'www' or 'docs')"
  type        = string
  default     = ""
}

variable "enable_auto_branch_creation" {
  description = "Enable automatic branch creation for pull requests"
  type        = bool
  default     = false
}

variable "auto_branch_creation_patterns" {
  description = "Patterns for automatic branch creation"
  type        = list(string)
  default     = ["feature/*", "fix/*"]
}

variable "additional_environment_variables" {
  description = "Additional environment variables for the build"
  type        = map(string)
  default     = {}
}

variable "branch_environment_variables" {
  description = "Environment variables specific to the main branch"
  type        = map(string)
  default     = {}
}
