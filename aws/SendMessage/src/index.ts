import {APIGatewayProxyEvent, APIGatewayProxyResult} from "aws-lambda";

const {
  AWS_FUNCTION_NAME,
  AWS_REGION,
  // AWS_TIMEOUT_THRESHOLD
  SLACK_ERROR_LOG,
  SLACK_MESSAGES_LOG,
}: any = process.env;

const { SlackErrorLogger, SlackLogger } = require('@unegma/logger'); // todo will need to change to import when updating or will cause weird errors like aws-utilities did
const slackLogger = new SlackLogger(SLACK_MESSAGES_LOG);
const slackErrorLogger = new SlackErrorLogger(SLACK_ERROR_LOG);

const headers = {
  "Content-Type" : "application/json",
  "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
  "Access-Control-Allow-Methods" : "OPTIONS,POST,GET,PUT,PATCH,DELETE", // HEAD?
  // Access-Control-Allow-Credentials needs to be set also to 'true' on the cors enabled resource
  "Access-Control-Allow-Credentials" : true, // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Origin" : "*",
  "X-Requested-With" : "*"
}

/**
 * Handler for AWS Function: FUNCTION_NAME defined in .env
 *
 * @param event
 * @param context
 * @returns {Promise<{body: string, statusCode: number}>}
 */
export const handler = async (event: APIGatewayProxyEvent, context: any = {}): Promise<APIGatewayProxyResult> => {
  console.log(`# Beginning ${AWS_FUNCTION_NAME}`); console.log(JSON.stringify(event)); console.log(context);
  // const queries = JSON.stringify(event.queryStringParameters);
  let message = "# Success";

  try {
    // @ts-ignore
    // let origin = event.headers.origin;
    // console.log(`Origin: ${origin}`);

    // very basic authorization
    // todo please make this more secure
    // if (typeof origin === "undefined" ||
    //     !['localhost:', "https://booking-system.unegma.io"].includes(origin)
    // ) {
    //   throw new Error('Unauthorized');
    // }

    // @ts-ignore
    // let data = JSON.parse(event.body);
    // console.log(`Data: ${JSON.stringify(data)}`);

    // await slackLogger.log('handler', data);

    // console.log(`Completed ${AWS_FUNCTION_NAME}`);

    return {
      headers: headers,
      statusCode: 200,
      body: message // body: JSON.stringify(response)
    };
  } catch(error: any) {
    // TODO REMOVE THIS IN PRODUCTION OR WILL DISPLAY VERBOSE ERRORS
    message = error.message; // todo may want messaging to only return the message if 'Unauthorized' (this will return sepcific error details)
    await slackErrorLogger.logError('handler', `${AWS_FUNCTION_NAME} failed.`, error);

    return {
      headers: headers,
      statusCode: 200, // todo should this be 500?
      body: message // body: JSON.stringify(response)
    };
  }

};

/**
 * Handler Functions
 */

/**
 * Sub Functions
 */



/**
 * API Gateway (todo find a way to make this easier) for CORS
 * GET 200, 401, 500 Access-Control-Allow-Headers, Access-Control-Allow-Origin, Access-Control-Allow-Credentials, Access-Control-Allow-Methods
 * OPTIONS 200, 401, 500
 */
