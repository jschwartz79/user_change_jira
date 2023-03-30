resource "aws_cloudwatch_event_rule" "configwatch_events" {
  name        = "configwatch"
  description = "Captures IAM::User events from AWS config"

  event_pattern = jsonencode({
    source : ["aws.config"],
    detail-type : ["Config Configuration Item Change"],
    detail : {
      configurationItemDiff : {
        changeType : ["CREATE", "UPDATE", "DELETE"]
      }
    }
  })

  depends_on = [
    aws_sqs_queue.config_change_queue
  ]
}

resource "aws_cloudwatch_event_target" "sqs_target" {
  rule = aws_cloudwatch_event_rule.configwatch_events.name
  arn  = aws_sqs_queue.config_change_queue.arn
  depends_on = [
    aws_sqs_queue.config_change_queue
  ]
}
