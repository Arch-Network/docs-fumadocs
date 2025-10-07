output "amplify_app_id" {
  description = "The ID of the Amplify app"
  value       = aws_amplify_app.fumadocs.id
}

output "amplify_app_arn" {
  description = "The ARN of the Amplify app"
  value       = aws_amplify_app.fumadocs.arn
}

output "amplify_default_domain" {
  description = "The default domain for the Amplify app"
  value       = aws_amplify_app.fumadocs.default_domain
}

output "amplify_app_url" {
  description = "The URL of the deployed application"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.fumadocs.default_domain}"
}

output "custom_domain_url" {
  description = "The custom domain URL (if configured)"
  value       = var.custom_domain != "" ? "https://${var.domain_prefix != "" ? "${var.domain_prefix}." : ""}${var.custom_domain}" : "Not configured"
}

output "amplify_branch_name" {
  description = "The name of the main branch"
  value       = aws_amplify_branch.main.branch_name
}

output "amplify_webhook_url" {
  description = "Webhook URL to trigger deployments"
  value       = "https://webhooks.amplify.${var.aws_region}.amazonaws.com/prod/webhooks?id=${aws_amplify_app.fumadocs.id}&token=<token>&operation=startbuild"
  sensitive   = true
}
