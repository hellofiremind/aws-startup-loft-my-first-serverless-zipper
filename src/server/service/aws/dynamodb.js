import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb'

const client = DynamoDBDocument.from(new DynamoDBClient({}))

export const get = (Key, TableName) =>
  client.get({
    Key,
    TableName
  })

export const put = (Item, TableName) =>
  client.put({
    Item,
    TableName
  })
