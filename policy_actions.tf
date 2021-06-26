variable "cloudwatch_actions" {
  description = "Default actions for managing Cloudwatch resources."
  default     = ["cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", ]
}

variable "sns_actions" {
  description = "Default permission for managing SNS resources."
  default = [
    "sns:CreateTopic",
    "sns:DeleteTopic",
    "sns:ListTagsForResource",
    "sns:TagResource",
    "sns:UntagResource",
    "sns:GetTopicAttributes",
  ]
}

variable "s3_cicd_actions" {
  description = "Default permission for saving CI/CD artifacts."
  default     = ["s3:PutObject", "s3:GetObject", ]
}

variable "lambda_actions" {
  description = "Default permission for managing lambda resources."
  default = [
    "lambda:ListTags",
    "lambda:TagResource",
    "lambda:UntagResource",
    "lambda:UpdateFunctionCode",
    "lambda:GetFunction",
    "lambda:CreateFunction",
    "lambda:DeleteFunction",
    "lambda:GetFunctionConfiguration",
    "lambda:UpdateFunctionConfiguration",
    "lambda:PutFunctionEventInvokeConfig",
    "lambda:UpdateFunctionEventInvokeConfig",
    "lambda:DeleteFunctionEventInvokeConfig",
    "lambda:AddPermission",
    "lambda:RemovePermission",
    "lambda:InvokeFunction"
  ]
}

variable "iam_sam_actions" {
  description = "Default IAM permissions for AWS SAM."
  default = [
    "iam:AttachRolePolicy",
    "iam:CreateRole",
    "iam:DeleteRole",
    "iam:DeleteRolePolicy",
    "iam:GetRole",
    "iam:UntagRole",
    "iam:ListRoleTags",
    "iam:TagRole",
    "iam:PassRole",
    "iam:DetachRolePolicy",
    "iam:PutRolePolicy",
    "iam:getRolePolicy",
  ]
}

variable "cloudformation_actions" {
  description = "Global permissions for managing cloudformation resources."
  default = [
    "cloudformation:CreateChangeSet",
    "cloudformation:GetTemplateSummary",
    "cloudformation:DescribeStacks",
    "cloudformation:DescribeStackEvents",
    "cloudformation:DeleteStack",
    "cloudformation:DescribeChangeSet",
    "cloudformation:ExecuteChangeSet",
  ]
}

variable "lambda_actions_global" {
  description = "Default permission for managing lambda (global) resources."
  default = [
    "lambda:CreateEventSourceMapping",
    "lambda:DeleteEventSourceMapping",
    "lambda:GetEventSourceMapping",
    "lambda:UpdateEventSourceMapping",
    "lambda:GetLayerVersion",
  ]
}

variable "describe_actions_global" {
  description = "Global permissions for descriptions."
  default = [
    "ec2:DescribeVpcs",
    "ec2:DescribeSubnets",
    "ec2:DescribeSecurityGroups"
  ]
}

variable "apigateway_actions_global" {
  description = "Default permission for managing API Gateways."
  default     = ["apigateway:*"]
}

variable "schedule_actions" {
  description = "Default permission for managing event (cron) resources."
  default = [
    "events:DeleteRule",
    "events:PutRule",
    "events:ListRules",
    "events:RemoveTargets",
    "events:PutTargets",
    "events:DescribeRule"
  ]
}

variable "sam_validate_global" {
  description = "Permission for running sam validate command."
  default     = ["iam:ListPolicies", ]
}

variable "sqs_actions" {
  description = "Permission for managing sqs."
  default = [
    "sqs:DeleteQueue",
    "sqs:CreateQueue",
    "sqs:GetQueueAttributes",
    "sqs:SetQueueAttributes"
  ]
}

variable "stack_output_actions" {
  description = "Permission for accessing outputs."
  default     = ["cloudformation:DescribeStacks", ]
}

variable "sns_subscribe_actions" {
  description = "Permission for subscribing to sns."
  default     = ["sns:Subscribe", "sns:Unsubscribe"]
}

variable "ssm_store_param" {
  description = "Permissions to store parameters"
  default = [
    "ssm:PutParameter",
    "ssm:AddTagsToResource",
    "ssm:AddTagsToResource",
    "ssm:RemoveTagsFromResource",
    "ssm:GetParameters"
  ]
}

variable "domain_certificate" {
  description = "Authorise generating domain certificate"
  default = [
    "acm:DeleteCertificate",
    "acm:DescribeCertificate",
    "route53:GetChange",
    "route53:GetHostedZone",
    "route53:ChangeResourceRecordSets"
  ]
}
