const LambdaTester = require('lambda-tester');
const proxyquire = require('proxyquire'); // use when connecting with real service
const proxyquireNCT = require('proxyquire').noCallThru(); // have to stub all dependencies
const sinon = require('sinon');
const chai = require('chai');
// @ts-ignore
const expect = chai.expect;
const FUNCTION_NAME = "CreateEvent";
require('dotenv').config({ path: '../../.env' }); // todo this will be different when moving directory

/**
 * !!!!!!
 * !! REMEMBER TO RUN `npm run compile-watch` WHILST RUNNING IN ORDER FOR DEBUGGING TO WORK OR SET UP AS SO:
 * !! https://medium.com/@kandros/getting-started-with-typescript-debugging-with-webstorm-breakpoints-f88aab1ffe5d
 * !! or add 'compile typescript' to 'before launch' in debug settings for each task
 *
 *  might also need esm stuff (todo find link) so can use imports
 *
 *  might also want to add to tsconfig:
 *  "inlineSources": true,
 *  "sourceMap": true,
 *
 * !!!!!!
 */
describe(FUNCTION_NAME, () => { // todo check if this works
    let event = require('./testData/testData.json');
    let awsStub;
    let arIncludes;
    let handler;

    beforeEach(() => {
        process.env.FUNCTION_NAME = FUNCTION_NAME;

        awsStub = {
            config: { update: sinon.stub().resolves({}) }
        };

        arIncludes = {
            errorHandler: {
                handleError: sinon.stub().resolves({}) // resolves returns a promise
            }
        };

        let stubs = {};
        if (process.env.LIVE_TESTING !== "true") {
            stubs = { ...stubs, 'aws-sdk': awsStub, 'eipDesign': arIncludes }
        }
        handler = proxyquire('../dist/index.js', stubs).handler;
    });

    afterEach(() => {
        sinon.restore(); // sinon automatically a sandbox now
    });

    it('should return a 200 response with body', async function() {
        // need to use function() in order to use this.timeout https://mochajs.org/#arrow-functions
        // only need this for developing using tests, don't need for when stubbing
        // this.timeout(400000);
        event.body = JSON.stringify(event.body);
        event.headers.origin = 'localhost:';

        return LambdaTester(handler)
            .event(event)
            .expectResult((result) => {
                console.log(`Test Ended with Result:`); console.log(result); // in separate console log or returns [object]
                expect(result.body).to.exist;
                expect(result.statusCode).to.eql(200);
            });
    });

});
