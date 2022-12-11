## File for Uploading

// todo does this remove the need for the publish function? how can they be combined?
data "archive_file" "function_archive" {
  type        = "zip"
#  source_dir  = "${path.module}/../lambda/dist"
#  output_path = "${path.module}/../lambda/dist/function.zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/../dist/function.zip"
}

# Send Message Function
resource "aws_lambda_function" "send-message" {
  function_name = "send-message"
  filename = data.archive_file.function_archive.output_path
  memory_size = 128
  timeout = 15

  handler = "index.handler"
  runtime = "nodejs16.x"

  source_code_hash = data.archive_file.function_archive.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      CONNECTIONS_TABLE = aws_dynamodb_table.SendMessage.name
    }
  }
}

resource "aws_cloudwatch_log_group" "SendMessageLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.send-message.function_name}"
  retention_in_days = 14
}
