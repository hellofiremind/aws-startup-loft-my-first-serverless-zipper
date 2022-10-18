data aws_caller_identity current {}

output account_id {
  value = data.aws_caller_identity.current.account_id
}

output api_endpoint_domain {
  value = local.api_gateway_domain
}

output frontend_url {
  value = local.domains[0]
}