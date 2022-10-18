import { get } from 'service/aws/dynamodb'
import { dynamodbTables, s3Buckets } from 'config/resources'
import { generateS3SignedURLForGet } from 'service/aws/s3'

export const check = async (req, res, next) => {
  const jobId = req.query.job_id

  const {
    Item: {
      complete = false,
      zipKey
    }
  } = await get({
    PK: `#ZIP_JOB#${jobId}`,
    SK: 'ZIP_JOB'
  }, dynamodbTables.main)

  if (!complete) {
    return res.json({
      complete
    })
  }

  const signedURL = await generateS3SignedURLForGet({
    Bucket: s3Buckets.export,
    Key: zipKey
  })

  res.json({
    complete,
    signedURL
  })
}
