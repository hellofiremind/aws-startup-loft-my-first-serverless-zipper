import * as ROUTES from 'common/constant/routes'
import express from 'helper/add-express'
import lambdaExpress from 'helper/lambda-express'
import * as zipMiddleware from 'middleware/zip'

const app = express()

app.get(ROUTES.ZIP_CHECK, zipMiddleware.check)
app.post(ROUTES.ZIP_REQUEST, zipMiddleware.request)

export const handler = (event, context) => lambdaExpress(event, context, app)
