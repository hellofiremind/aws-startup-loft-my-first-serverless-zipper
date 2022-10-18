import _ from 'lodash'
import terraformState from 'infrastructure/terraform-state.json'

const getFromTerraformState = (prefix) => _.reduce(terraformState, (result, value, name) => {
  if (name.startsWith(prefix)) {
    const newName = name.replace(prefix, '')
    result = {
      ...result,
      [newName]: value
    }
  }

  return result
}, {})

export const dynamodbTables = getFromTerraformState('dynamodb_')
export const kmsKeys = getFromTerraformState('kms_id_')
export const rds = getFromTerraformState('rds_')
export const s3Buckets = getFromTerraformState('s3_bucket_')
export const sqsQueues = getFromTerraformState('sqs_')
export const frontend = getFromTerraformState('frontend_')
export const cognito = getFromTerraformState('cognito_')
