# Credit to: "https://github.com/eunchurn/terraform-typescript-lambda-apigateway"
# Credit to: "https://github.com/anwarkh"


locals {
  author = "Tim Coleman"
  email = "tim@unegma.com"

  tags = {
    Name = "lambda-apigateway-demo"
    GitRepo = "https://github.com/unegma"
    ManagedBy = "Terraform"
    Owner = "${local.email}"
  }
}
