import { v4 as uuidv4 } from 'uuid'
import { put } from 'service/aws/dynamodb'
import { dynamodbTables, sqsQueues } from 'config/resources'
import { send } from 'service/aws/sqs'

export const request = async (req, res, next) => {
  const jobId = uuidv4()
  // const s3Prefix = `${jobId}/` this prefix can be the dynamic key you want to zip up in S3, for now it's just a test
  const s3Prefix = 'my-special-files/'

  await put({
    PK: `#ZIP_JOB#${jobId}`,
    SK: 'ZIP_JOB',
    s3Prefix
  }, dynamodbTables.main)

  await send({
    MessageBody: jobId,
    MessageGroupId: 'zip-request',
    QueueUrl: sqsQueues.zip_url
  })

  res.json({ jobId })
}
