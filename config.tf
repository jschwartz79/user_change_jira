resource "aws_config_configuration_recorder" "recorder" {
  name     = "default"
  role_arn = "arn:aws:iam::${var.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::IAM::User"
    ]
  }
}

resource "aws_config_delivery_channel" "config_delivery" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}
