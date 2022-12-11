## Role
resource "aws_iam_role" "lambda_role" {
  name = "send-message-role"
  tags = local.tags
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

## Policies
data "aws_iam_policy_document" "CloudWatchLogsPolicyDocument" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "cloudwatch:PutMetricData",
      "kms:*"
    ]
    resources = ["*"] // todo should this also be limited to arn?
  }
}

data "aws_iam_policy_document" "executeApiPolicyDocument" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "execute-api:Invoke",
      "execute-api:ManageConnections"
    ]
    resources = ["*"]

    // todo should this be this?
#    Resource: [
#      "${aws_apigatewayv2_api.send_message.execution_arn}",
#      "${aws_apigatewayv2_api.send_message.execution_arn}/index/*/*"
#    ]
  }
}

// todo limit resources above?

// todo does there need to be a lambda_persmission too? like this?
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

resource "aws_iam_policy" "CloudWatchLogsPolicy" {
  policy = data.aws_iam_policy_document.CloudWatchLogsPolicyDocument.json
}
resource "aws_iam_policy" "ExecuteApiPolicy" {
  policy = data.aws_iam_policy_document.executeApiPolicyDocument.json
}

resource "aws_iam_policy" "DynamoDBCrudPolicy" {
  name = "DynamoDBCrudPolicy"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable"
    ],
    "Resource": [
      "${aws_dynamodb_table.SendMessage.arn}",
      "${aws_dynamodb_table.SendMessage.arn}/index/*"
    ]
  }]
}
EOT
}

## Attach Policies to Role
resource "aws_iam_policy_attachment" "CloudWatchLogsPolicy_iam_policy_attachment" {
  name = "send-message-aws_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]
  policy_arn = aws_iam_policy.CloudWatchLogsPolicy.arn
}

resource "aws_iam_policy_attachment" "ExecuteApiPolicy_iam_policy_attachment" {
  name = "send-message-aws_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]
  policy_arn = aws_iam_policy.ExecuteApiPolicy.arn
}

resource "aws_iam_policy_attachment" "DynamoDBCrudPolicy_iam_policy_attachment" {
  name = "send-message-DynamoDBCrudPolicy_iam_policy_attachment"
  roles = [ aws_iam_role.lambda_role.name ]
  policy_arn = aws_iam_policy.DynamoDBCrudPolicy.arn
}

