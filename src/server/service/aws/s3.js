import { getSignedUrl } from '@aws-sdk/s3-request-presigner'
import { S3Client, GetObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3'

const client = new S3Client()

export const generateS3SignedURLForGet = (params) =>
  getSignedUrl(client, new GetObjectCommand(params), { expiresIn: 3600 })

export const generateS3SignedURLForPut = (params) =>
  getSignedUrl(client, new PutObjectCommand(params), { expiresIn: 3600 })
