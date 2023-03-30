data "archive_file" "zip_config_change" {
  type        = "zip"
  output_path = "config_change.zip"
  source_file = "config_change.py"
}

resource "aws_lambda_function" "config_change_lambda" {
  filename      = "config_change.zip"
  function_name = "identify_config_change"
  role          = aws_iam_role.lambda_role.arn

  handler          = "config_change.lambda_handler"
  runtime          = "python3.7"
  timeout          = 30
  source_code_hash = data.archive_file.zip_config_change.output_base64sha256

  environment {
    variables = {
      "JIRA_USER"       = var.jira_user,
      "JIRA_TOKEN_NAME" = aws_ssm_parameter.jira_token.name
      "JIRA_PROJECT"    = var.jira_project
      "JIRA_URL"        = var.jira_url
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    data.archive_file.zip_config_change
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_events" {
  event_source_arn = aws_sqs_queue.config_change_queue.arn
  function_name    = aws_lambda_function.config_change_lambda.arn
  depends_on = [
    aws_sqs_queue.config_change_queue
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/identify_config_change"
}
