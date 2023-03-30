resource "aws_ssm_parameter" "jira_token" {
  name        = "/config_tracker/jira_token"
  description = "Token for the Jira integration"
  type        = "SecureString"
  value       = var.jira_token
}
