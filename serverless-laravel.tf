variable "serverless-laravel" {
  default = "serverless-laravel*"
  type    = string
}

variable "serverless-laravel-cicd-name" {
  default = "serverless-laravel-cicd"
  type    = string
}

resource "aws_iam_user" "serverless-laravel-cicd" {
  name = var.serverless-laravel-cicd-name
  tags = {
    Name = var.serverless-laravel-cicd-name
  }
}

data "aws_iam_policy_document" "serverless-laravel-serverless" {
  statement {
    sid     = replace("${var.serverless-laravel-cicd-name}-serverless", "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.lambda_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-${var.prod}-${var.serverless-laravel}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-${var.test}-${var.serverless-laravel}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-${var.prod}-${var.serverless-laravel}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-${var.test}-${var.serverless-laravel}",
      "arn:aws:cloudwatch:${var.eu_west_1}:${var.aws_account_id}:alarm:${var.org}-${var.prod}-${var.serverless-laravel}",
      "arn:aws:cloudwatch:${var.eu_west_1}:${var.aws_account_id}:alarm:${var.org}-${var.test}-${var.serverless-laravel}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-${var.prod}-${var.serverless-laravel}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-${var.test}-${var.serverless-laravel}",
    ]
  }
}

resource "aws_iam_policy" "serverless-laravel" {
  name   = "AuthFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-serverless.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-serverless" {
  policy_arn = aws_iam_policy.serverless-laravel.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-global-resources" {
  statement {
    sid     = replace("${var.serverless-laravel-cicd-name}-global", "-", "")
    actions = concat(var.lambda_actions_global, var.sam_validate, var.apigateway_actions_global)
    resources = [
    "*"]
  }
}

resource "aws_iam_policy" "serverless-laravel-global" {
  name   = "GlobalAuthFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-global-resources.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-global" {
  policy_arn = aws_iam_policy.serverless-laravel-global.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-domain" {
  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-request-certificate", "-", "")
    actions = [
    "acm:RequestCertificate"]
    resources = [
    "*"]
  }

  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-change-certificate", "-", "")
    actions = [
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:acm:${var.org}-${var.test}-${var.serverless-laravel}:${var.aws_account_id}:certificate/*",
      "arn:aws:route53:::hostedzone/${var.base_domain_route_53_hosted_zone_id}",
      "arn:aws:route53:::change/*"
    ]
  }
}


resource "aws_iam_policy" "serverless-laravel-domain" {
  name   = "DomainManagerFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-domain.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-domain" {
  policy_arn = aws_iam_policy.serverless-laravel-domain.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}
