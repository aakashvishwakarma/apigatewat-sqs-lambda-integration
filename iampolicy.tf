#IAM role and policy for API with  SQS
resource "aws_iam_role" "apiSQS" {
  name = "apigateway_sqs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# data "template_file" "gateway_policy" {
#   template = file("apigatewaypolicy/apigateway.json")

#   vars = {
#     sqs_arn   = aws_sqs_queue.queue.arn
#   }
# }
data "aws_iam_policy_document" "api_customer_policy" {
    version = "2012-10-17"

    statement {
      actions = ["logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        effect = "Allow"
        resources = [ "*" ]
    }

    statement {
      actions = [ "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ]
        effect = "Allow"
        resources = [ "arn:aws:sqs:*" ]
    }
    statement {
      actions = ["sqs:ListQueues"]
      effect = "Allow"
      resources = [ "*" ]
    }
}

data "aws_iam_policy_document" "lambda_customer_policy" {
  version = "2012-10-17"

  statement {

    actions = [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes"
    ]
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]
  }

  statement {

    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}


resource "aws_iam_policy" "api_policy" {
  name = "api-sqs-cloudwatch-policy"

  policy = data.aws_iam_policy_document.api_customer_policy.json
}


resource "aws_iam_role_policy_attachment" "api_exec_role" {
  role       =  aws_iam_role.apiSQS.name
  policy_arn =  aws_iam_policy.api_policy.arn
}

# Add a Lambda permission that allows the specific SQS to invoke it

# data "template_file" "lambda_policy" {
#   template = file("apigatewaypolicy/lambda.json")

#   vars = {
#     sqs_arn   = aws_sqs_queue.queue.arn
#   }
# }

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_policy_db"
  description = "IAM policy for lambda Being invoked by SQS"

  policy = data.aws_iam_policy_document.lambda_customer_policy.json
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda-exec-role"
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

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}