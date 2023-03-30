resource "aws_s3_bucket" "config_bucket" {
  bucket        = "config-bucket-${var.account_id}"
  force_destroy = false
}

resource "aws_s3_bucket_acl" "config_bucket_acl" {
  bucket = aws_s3_bucket.config_bucket.id
  acl    = "private"
}
