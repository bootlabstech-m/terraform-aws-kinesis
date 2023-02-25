variable "region" {
  description = "The region"
  type        = string
}
variable "policy_action" {
  description = "permissions included in policy."
  type        = list (string)
}
variable "firehose_details" {
  description = "firehose details."
  type        = list (any)
}
variable "role_arn" {
  description = " The ARN of the IAM role"
  type = string
}
