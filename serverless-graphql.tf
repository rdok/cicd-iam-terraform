variable "serverless-graphql" {
  default = "serverless-graphql*"
  type    = string
}

variable "serverless-graphql-cicd-iam-name" {
  default = "serverless-graphql-cicd"
  type    = string
}

resource "aws_iam_user" "serverless-graphql-cicd" {
  name = var.serverless-graphql-cicd-iam-name
  tags = { Name = var.serverless-graphql-cicd-iam-name }
}

data "aws_iam_policy_document" "serverless-graphql-serverless" {
  statement {
    sid     = replace("${var.serverless-graphql-cicd-iam-name}-serverless", "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.lambda_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-${var.prod}-${var.serverless-graphql}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-${var.test}-${var.serverless-graphql}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-${var.prod}-${var.serverless-graphql}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-${var.test}-${var.serverless-graphql}",
      "arn:aws:cloudwatch:${var.eu_west_1}:${var.aws_account_id}:alarm:${var.org}-${var.prod}-${var.serverless-graphql}",
      "arn:aws:cloudwatch:${var.eu_west_1}:${var.aws_account_id}:alarm:${var.org}-${var.test}-${var.serverless-graphql}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-${var.prod}-${var.serverless-graphql}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-${var.test}-${var.serverless-graphql}",
    ]
  }
}

resource "aws_iam_policy" "serverless-graphql-serverless" {
  name   = "AuthFor${var.serverless-graphql-cicd-iam-name}"
  path   = "/${var.serverless-graphql-cicd-iam-name}/"
  policy = data.aws_iam_policy_document.serverless-graphql-serverless.json
}

resource "aws_iam_user_policy_attachment" "serverless-graphql-serverless" {
  policy_arn = aws_iam_policy.serverless-graphql-serverless.arn
  user       = aws_iam_user.serverless-graphql-cicd.name
}

data "aws_iam_policy_document" "serverless-graphql-global-resources" {
  statement {
    sid       = replace("${var.serverless-graphql-cicd-iam-name}-global", "-", "")
    actions   = concat(var.lambda_actions_global, var.sam_validate_global, var.apigateway_actions_global)
    resources = ["*"]
  }
}

resource "aws_iam_policy" "serverless-graphql-global" {
  name   = "GlobalAuthFor${var.serverless-graphql-cicd-iam-name}"
  path   = "/${var.serverless-graphql-cicd-iam-name}/"
  policy = data.aws_iam_policy_document.serverless-graphql-global-resources.json
}

resource "aws_iam_user_policy_attachment" "serverless-graphql-global" {
  policy_arn = aws_iam_policy.serverless-graphql-global.arn
  user       = aws_iam_user.serverless-graphql-cicd.name
}
