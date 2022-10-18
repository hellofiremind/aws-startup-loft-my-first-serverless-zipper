// import { session } from 'middleware/auth'
import { frontend } from 'config/resources'
import bodyParser from 'body-parser'
import cookieParser from 'cookie-parser'
import express from 'express'
import helmet from 'helmet'
import noCache from 'nocache'
import cors from 'cors'

const origins = [
  `https://${frontend.url}`
]

if (process.env.BUILD_STAGE !== 'production') {
  origins.push('https://localhost:4000')
}

export default () => {
  const app = express()

  app.use(cookieParser())
  app.use(bodyParser.json())
  app.use(bodyParser.urlencoded({ extended: true }))
  app.use(helmet())
  app.use(helmet.contentSecurityPolicy())
  app.use(helmet.referrerPolicy({ policy: 'same-origin' }))
  app.use(noCache())
  app.use(cors({
    allowedHeaders: ['Content-Type'],
    credentials: true,
    methods: ['GET', 'PUT', 'POST', 'OPTIONS', 'PATCH', 'DELETE', 'UPDATE'],
    origin: origins
  }))

  return app
}
