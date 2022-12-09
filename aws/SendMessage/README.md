# Readme

When adding a new lambda function:

* duplicate this
* set timeout
* make sure any required environment variables are added to function
* make sure to add to publish and deploy all scripts 

todo Remember to add install and upload paths to top level package.json


* todo figure out what is going on with environment.json
* tidy up so do things in order
* try the example with account id again for creating rest api

Info from here: 
* https://cloudnamaste.com/how-to-create-an-api-gateway-rest-api-using-aws-cli/
* https://bobbyhadz.com/blog/aws-cli-create-lambda-function
* https://medium.com/@schogini/aws-apigateway-and-lambda-a-get-mehod-cli-demo-8a05e82df275

## to delete and start over
* run the delete commands
* remove the environment variables
* delete the logs
---

# Examples using jq for pulling values from json

## Create a HTTP API
API_ID=$(aws apigatewayv2 create-api \
--name myapp_http_api \
--protocol-type HTTP \
--target $LAMBDA_ARN | jq -r .ApiId)

## Get integration id
INTEGRATION_ID=$(aws apigatewayv2 get-integrations \
--api-id $API_ID | jq -r .Items[].IntegrationId)

## Provide access to API gateway to invoke the lambda function
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)
