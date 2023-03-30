variable "jira_user" {
  description = "Jira user for API integration"
  type        = string
}

variable "jira_token" {
  description = "Jira token for API integration"
  type        = string
  sensitive   = true
}

variable "jira_project" {
  description = "Jira project code for ticket creation"
  type        = string
}

variable "jira_url" {
  description = "Organization specific URL for Jira"
  type        = string
}

variable "account_id" {
  description = "Account ID"
  type        = string
}
