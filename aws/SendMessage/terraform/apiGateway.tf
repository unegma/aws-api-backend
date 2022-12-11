resource "aws_apigatewayv2_api" "send_message" {
  name                       = "SendMessage"
  description                = "Send Message Example"
  protocol_type              = "HTTP"
  cors_configuration {
    allow_headers = [
      "Content-Type",
      "X-Amz-Date",
      "Authorization",
      "X-Api-Key",
      "X-Amz-Security-Token",
      "X-Amz-User-Agent"
    ]
    allow_methods = [
      "OPTIONS",
      "POST",
      "GET",
      "PUT",
      "DELETE"
    ]
    allow_origins = [
      "*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "HttpApiLogGroup" {
  name = "/aws/http-api/send-message-live"
}

// POST Send Message
resource "aws_lambda_permission" "SendMessageLambdaPermissionHttpApi" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send-message.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.send_message.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_integration" "HttpApiIntegrationSendMessage" {
  api_id = aws_apigatewayv2_api.send_message.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.send-message.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds = 6500
}

resource "aws_apigatewayv2_route" "HttpApiRouteSendMessage" {
  api_id = aws_apigatewayv2_api.send_message.id
  route_key = "POST /message"
  target = "integrations/${aws_apigatewayv2_integration.HttpApiIntegrationSendMessage.id}"
  depends_on = [aws_apigatewayv2_integration.HttpApiIntegrationSendMessage]
}

## Stage
resource "aws_apigatewayv2_stage" "HttpApiStage" {
  api_id = aws_apigatewayv2_api.send_message.id
  name = "live"
  auto_deploy = true
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit = 10
    throttling_rate_limit = 10
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.HttpApiLogGroup.arn
    format = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\", \"errorIntegration\":\"$context.integrationErrorMessage\"}"
  }
  depends_on = [aws_cloudwatch_log_group.HttpApiLogGroup]
}
