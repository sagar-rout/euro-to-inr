terraform {
  required_providers {
    aws = {
      source    = "hashicorp/aws",
      "version" = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "iam_euro_to_inr_lambda" {
  name = "iam_euro_to_inr_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "euro_to_inr" {
  function_name = "euro_to_inr"
  handler       = "index.handler"
  role          = aws_iam_role.iam_euro_to_inr_lambda.arn
  runtime       = "nodejs12.x"
  timeout       = 10
  description   = "Convert euro to inr and send notification"

  filename = "euro_to_inr.zip"

  source_code_hash = filebase64sha256("euro_to_inr.zip")

  environment {
    variables = {
      API_KEY        = "GET_API_KEY_FIXIR",
      SMTP_USERNAME  = "smtp@gmail.com",
      SMTP_PASSWORD  = "testing",
      RECEIVER_EMAIL = "smtp@gmail.com"
    }
  }

}

resource "aws_cloudwatch_log_group" "euro_to_inr_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.euro_to_inr.function_name}"
  retention_in_days = 1 // I kept 1 because otherwise aws will charge 
}

resource "aws_iam_policy" "euro_to_inr_logging_policy" {
  name        = "euro_to_inr"
  path        = "/"
  description = "IAM policy for euro to inr lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "euro_to_inr_policy_attachment" {
  role       = aws_iam_role.iam_euro_to_inr_lambda.name
  policy_arn = aws_iam_policy.euro_to_inr_logging_policy.arn
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every_day"
  description         = "Fires every day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_day" {
  rule      = "${aws_cloudwatch_event_rule.every_day.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.euro_to_inr.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.euro_to_inr.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_day.arn}"
}