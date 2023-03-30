resource "aws_sqs_queue" "config_change_queue" {
  name          = "ConfigChanges"
  delay_seconds = 120 # Allow for arrival of CloudTrail events
}

