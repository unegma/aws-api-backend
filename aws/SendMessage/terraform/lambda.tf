## File for Uploading
data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/dist"
  output_path = "${path.module}/../lambda/dist/function.zip"
}

# Send Message Function
resource "aws_lambda_function" "send-message" {
  function_name = "send-message"
#  filename = data.archive_file.function_archive.output_path
  memory_size = 128
  timeout = 15

  handler = "index.handler"
  runtime = "nodejs16.x"

#  source_code_hash = filebase64sha256(data.archive_file.function_archive)

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      CONNECTIONS_TABLE = aws_dynamodb_table.SendMessage.name
    }
  }
}

#resource "aws_lambda_permission" "apigw" {
#  statement_id  = "AllowAPIGatewayInvoke"
#  action = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.SendMessage.function_name
#  principal = "apigateway.amazonaws.com"
#
#  #   # The "/*/*" portion grants access from any method on any resource
#  #   # within the API Gateway REST API.
#  #   # source_arn = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/*"
#  #   source_arn = "${aws_apigatewayv2_api.api_gateway_rest_api.execution_arn}/*/*"
#}

resource "aws_cloudwatch_log_group" "SendMessageLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.send-message.function_name}"
  retention_in_days = 14
}
