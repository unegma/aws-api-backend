output "api_base_url" {
  value = aws_apigatewayv2_stage.HttpApiStage.invoke_url
  description = "The public URl of the API"
}
