#
# DynamoDB table resources.
# todo how do you share tables between configurations?
#
resource "aws_dynamodb_table" "SendMessage" {
  name = "SendMessage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}

