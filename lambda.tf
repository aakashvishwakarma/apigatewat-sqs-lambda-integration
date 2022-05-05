data "archive_file" "lambda_with_dependencies" {
  type        = "zip"
  source_dir  = "python-file/"
  output_path = "python-file-zip/demo.zip"

}

resource "aws_lambda_function" "lambda_sqs" {
  function_name    = var.function_name
  handler          = "demo.lambda_handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.7"
  filename         = data.archive_file.lambda_with_dependencies.output_path
  source_code_hash = filebase64sha256("${data.archive_file.lambda_with_dependencies.output_path}")

  timeout          = 30
  memory_size      = 128

  depends_on = [
    aws_iam_role_policy_attachment.lambda_role_policy
  ]
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_sqs.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.queue.arn
}

# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn =  aws_sqs_queue.queue.arn
  function_name    =  aws_lambda_function.lambda_sqs.arn

  depends_on = [
    aws_sqs_queue.queue
  ]
}