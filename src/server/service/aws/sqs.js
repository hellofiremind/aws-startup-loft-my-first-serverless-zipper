import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs'

const client = new SQSClient()

export const send = (input) =>
  client.send(new SendMessageCommand(input))
