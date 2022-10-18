import awsServerlessExpress from 'aws-serverless-express'
import awsServerlessExpressMiddleware from 'aws-serverless-express/middleware'
// import { teardown } from 'middleware/generic/teardown'

let serverlessExpressServer

export default (event, context, app) => {
  app.use(awsServerlessExpressMiddleware.eventContext())
  // app.use(teardown())

  if (!serverlessExpressServer) {
    serverlessExpressServer = awsServerlessExpress.createServer(app)
  }

  return awsServerlessExpress.proxy(serverlessExpressServer, event, context)
}
