resource "aws_iam_role" "lambda_role" {
  name = "LambdaSSMAccess"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCloudTrail_ReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ]
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "AllowSSMExecution"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "ssm:StartAutomationExecution",
              "ssm:GetParameter*",
              "ssm:StartAutomationExecution",
              "cloudformation:CreateStack",
              "cloudformation:DeleteStack",
              "cloudformation:DescribeStacks",
              "cloudformation:CreateChangeSet",
              "iam:CreateRole",
              "iam:DeleteRole",
              "iam:GetRole",
              "iam:GetRolePolicy",
              "iam:PutRolePolicy",
              "iam:DeleteRolePolicy",
              "iam:PassRole",
              "lambda:GetFunction",
              "lambda:CreateFunction",
              "lambda:DeleteFunction",
              "lambda:InvokeFunction",
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }

  inline_policy {
    name = "LambdaIdentifyChangeExecution"
    policy = jsonencode(
      {
        Version : "2012-10-17",
        Statement : [
          {
            Effect : "Allow",
            Action : "logs:CreateLogGroup",
            Resource : "arn:aws:logs:us-east-1:${var.account_id}:*"
          },
          {
            Effect : "Allow",
            Action : [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            Resource : [
              "arn:aws:logs:us-east-1:${var.account_id}:log-group:/aws/lambda/IdentifyUserChange:*"
            ]
          }
        ]
      }
    )
  }
}
