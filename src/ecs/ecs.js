const { PassThrough } = require('stream')
const { basename } = require('path')
const { SQS } = require('@aws-sdk/client-sqs')
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb')
const { DynamoDBDocument } = require('@aws-sdk/lib-dynamodb')
const { Upload } = require('@aws-sdk/lib-storage')
const { S3 } = require('@aws-sdk/client-s3')
const JSZip = require('jszip')
const _ = require('lodash')
const state = require('./terraform-state.json')

const s3Client = new S3()
const sqsClient = new SQS()
const dynamoDBClient = DynamoDBDocument.from(new DynamoDBClient({}))

const CHUNK_SIZE = 25
const TIMEOUT = 30000

const queueURL = state.sqs_zip_url
const params = {
  AttributeNames: ['SentTimestamp'],
  MaxNumberOfMessages: 1,
  MessageAttributeNames: ['All'],
  QueueUrl: queueURL,
  VisibilityTimeout: 120,
  WaitTimeSeconds: 0
}

const sleep = () => new Promise((resolve) => setTimeout(resolve, TIMEOUT))

const run = async () => {
  try {
    const data = await sqsClient.receiveMessage(params)

    if (data.Messages) {
      await Promise.all(data.Messages.map(async (message) => {
        const jobId = message.Body
        console.log(jobId)
        const s3Prefix = await getS3Prefix(jobId)
        console.log('s3Prefix', s3Prefix)

        const zipOutputS3Key = await uploadZipFileToS3(jobId, s3Prefix)
        console.log(zipOutputS3Key)

        await updateDBEntry(jobId, zipOutputS3Key, s3Prefix)
        await deleteMessage(message)
      }))
    } else {
      console.log(data)
      console.log('No messages to delete')
    }
  } catch (error) {
    console.log('Receive Error', error)
  }
}

const getS3Prefix = async (jobId) => {
  const {
    Item: {
      s3Prefix
    }
  } = await dynamoDBClient.get({
    Key: {
      PK: `#ZIP_JOB#${jobId}`,
      SK: 'ZIP_JOB'
    },
    TableName: state.dynamodb_main
  })

  return s3Prefix
}

const uploadZipFileToS3 = async (jobId, prefix) => {
  const zipKey = `${jobId}.zip`

  const {
    Contents: items
  } = await s3Client.listObjectsV2({
    Bucket: state.s3_bucket_input,
    Prefix: prefix
  })

  console.log('Zipping up', items.length)
  const pass = new PassThrough()
  const zip = await createZipFile(items.filter(({ Key }) => Key.endsWith('.pdf') || Key.endsWith('.jpeg') || Key.endsWith('.png')))

  zip.pipe(pass)

  console.log('Uploading zip')
  const upload = new Upload({
    client: s3Client,
    params: {
      Body: pass,
      Bucket: state.s3_bucket_export,
      Key: zipKey
    }
  })

  console.log(await upload.done())

  return zipKey
}

const createZipFile = async (items) => {
  const zip = new JSZip()
  const chunks = _.chunk(items, CHUNK_SIZE)

  for (let chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
    const chunk = chunks[chunkIndex]
    const s3 = new S3()

    for (let itemIndex = 0; itemIndex < chunk.length; itemIndex++) {
      const {
        Key: key
      } = chunk[itemIndex]
      console.log('Getting key', key, itemIndex)

      const {
        Body: body
      } = await s3.getObject({
        Bucket: state.s3_bucket_input,
        Key: key
      })

      console.log(`Zipping ${key}`, itemIndex)
      zip.file(basename(key), body)
    }
  }

  return zip.generateNodeStream({ streamFiles: true })
}

const updateDBEntry = (jobId, zipKey, s3Prefix) =>
  dynamoDBClient.put({
    Item: {
      PK: `#ZIP_JOB#${jobId}`,
      SK: 'ZIP_JOB',
      complete: true,
      s3Prefix,
      zipKey
    },
    TableName: state.dynamodb_main
  })

const deleteMessage = (message) =>
  sqsClient.deleteMessage({
    QueueUrl: queueURL,
    ReceiptHandle: message.ReceiptHandle
  })

const start = async () => {
  while (true) {
    await run()
    await sleep()
  }
}

start().then(console.log.bind(console), console.log.bind(console))
