# Readme

When adding a new lambda function:

* duplicate this
* set timeout
* make sure any required environment variables are added to function
* make sure to add to publish and deploy all scripts 

todo Remember to add install and upload paths to top level package.json



todo figure out what is going on with environment.json
tidy up so do things in order
find the articles which you read previously
add the links to the articles in here
try the example with account id again for creating rest api

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
