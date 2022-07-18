import {APIGatewayProxyEvent, APIGatewayProxyResult} from "aws-lambda";
const axios = require('axios');

const {
  AWS_REGION,
  AWS_LAMBDA_FUNCTION_NAME = 'Unegma_BookingSystem_CreateEvent',
  // AWS_TIMEOUT_THRESHOLD
  SLACK_ERROR_LOG, // NEED ENVIRONMENT VARIABLES FOR THOSE USED IN IMPORTS
}: any = process.env;

import { AWSUtilities, DBUtilities } from '@unegma/aws-utilities';
const { SlackErrorLogger, SlackLogger } = require('@unegma/logger'); // todo will need to change to import when updating or will cause weird errors like aws-utilities did
const slackErrorLogger = new SlackErrorLogger(SLACK_ERROR_LOG);
const awsUtilities = new AWSUtilities(AWS_REGION, SLACK_ERROR_LOG);
const dbUtilities = new DBUtilities(AWS_REGION, SLACK_ERROR_LOG);

/**
 *
 * @param event
 * @param context
 * @returns {Promise<{body: string, statusCode: number}>}
 */
export const handler = async (event: APIGatewayProxyEvent, context: any = {}): Promise<APIGatewayProxyResult> => {
  console.log(`# Beginning ${AWS_LAMBDA_FUNCTION_NAME}`); console.log(JSON.stringify(event)); console.log(context);
  // const queries = JSON.stringify(event.queryStringParameters);

  let message = "# Success";
  try {
    // @ts-ignore
    let origin = event.headers.origin;
    console.log(`Origin: ${origin}`);

    // very basic authorization
    // todo please make this more secure
    if (typeof origin === "undefined" ||
        !['localhost:', "https://booking-system.unegma.io"].includes(origin)
    ) {
      throw new Error('Unauthorized');
    }


    // @ts-ignore
    let data = JSON.parse(event.body);
    console.log(`Data: ${JSON.stringify(data)}`);


    // let data = await dbUtilities.getFromDB(AWS_LAMBDA_FUNCTION_NAME, 'UserAndKey', null, '');
    // console.log(data);

    // if (data.UserData) {
    //   message = JSON.stringify(data.UserData);
    // }

    // // event["queryStringParameters"]['queryparam1']
    // let walletAddress = event.queryStringParameters ? event.queryStringParameters['address'] : '';
    //
    // // Make a request for a user with a given ID
    // let response = await axios.get(`https://api.poap.xyz/actions/scan/${walletAddress}`);
    // let data = response.data;
    //
    // console.log(data);




    // Refer to the Node.js quickstart on how to setup the environment:
    // https://developers.google.com/calendar/quickstart/node
    // Change the scope to 'https://www.googleapis.com/auth/calendar' and delete any
    // stored credentials.

    let eventData = {
      'summary': data.summary,
      'location': '800 Howard St., San Francisco, CA 94103',
      'description': 'A chance to hear more about Google\'s developer products.',
      'start': {
        'dateTime': '2015-05-28T09:00:00-07:00',
        'timeZone': 'America/Los_Angeles',
      },
      'end': {
        'dateTime': '2015-05-28T17:00:00-07:00',
        'timeZone': 'America/Los_Angeles',
      },
      'recurrence': [
        'RRULE:FREQ=DAILY;COUNT=2'
      ],
      'attendees': [
        {'email': 'lpage@example.com'},
        {'email': 'sbrin@example.com'},
      ],
      'reminders': {
        'useDefault': false,
        'overrides': [
          {'method': 'email', 'minutes': 24 * 60},
          {'method': 'popup', 'minutes': 10},
        ],
      },
    };

    // calendar.events.insert({
    //   auth: auth,
    //   calendarId: 'primary',
    //   resource: event,
    // }, function(err, event) {
    //   if (err) {
    //     console.log('There was an error contacting the Calendar service: ' + err);
    //     return;
    //   }
    //   console.log('Event created: %s', event.htmlLink);
    // });

    let message = eventData;


  } catch(error: any) {
    // TODO REMOVE THIS IN PRODUCTION OR WILL DISPLAY VERBOSE ERRORS
    message = error.message; // todo may want messaging to only return the message if 'Unauthorized' (this will return sepcific error details)
    await slackErrorLogger.logError('handler', `${AWS_LAMBDA_FUNCTION_NAME} failed.`, error);
  }
  console.log(`Completed ${AWS_LAMBDA_FUNCTION_NAME}`);

  // Access-Control-Allow-Credentials needs to be set also to 'true' on the cors enabled resource
  return {
    headers: {
      "Content-Type" : "application/json",
      "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Methods" : "OPTIONS,POST,GET,PUT,PATCH,DELETE", // HEAD?
      "Access-Control-Allow-Credentials" : true, // Required for cookies, authorization headers with HTTPS
      "Access-Control-Allow-Origin" : "*",
      "X-Requested-With" : "*"
    },
    statusCode: 200,
    // body: JSON.stringify(response)
    body: message
  };
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
