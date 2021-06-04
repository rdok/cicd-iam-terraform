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

data "aws_iam_policy_document" "serverless-laravel" {
  statement {
    sid     = replace(var.serverless-laravel-cicd-name, "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.lambda_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-*-${var.serverless-laravel}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.serverless-laravel}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-*-${var.serverless-laravel}",
    ]
  }
}

resource "aws_iam_policy" "serverless-laravel" {
  name   = "AuthFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel" {
  policy_arn = aws_iam_policy.serverless-laravel.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-certificate" {
  statement {
    sid     = replace("${var.serverless-laravel-cicd-name}-certificate", "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.serverless-laravel}/*",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.serverless-laravel}",
    ]
  }
}

resource "aws_iam_policy" "serverless-laravel-certificate" {
  name   = "AuthFor${var.serverless-laravel-cicd-name}Certificate"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-certificate.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-certificate" {
  policy_arn = aws_iam_policy.serverless-laravel-certificate.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-certificate-gen" {
  statement {
    sid       = replace("${var.serverless-laravel-cicd-name}-request-certificate", "-", "")
    actions   = ["acm:RequestCertificate", "acm:DeleteCertificate", "acm:DescribeCertificate"]
    resources = ["*"]
  }

  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-change-certificate", "-", "")
    actions = [
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:acm:${var.org}-*-${var.serverless-laravel}:${var.aws_account_id}:certificate/*",
      "arn:aws:route53:::hostedzone/${var.base_domain_route_53_hosted_zone_id}",
      "arn:aws:route53:::change/*"
    ]
  }
}

resource "aws_iam_policy" "serverless-laravel-certificate-gen" {
  name   = "DomainManagerFor${var.serverless-laravel-cicd-name}CertificateGen"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-certificate-gen.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-certificate-gen" {
  policy_arn = aws_iam_policy.serverless-laravel-certificate-gen.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-s3-storage" {
  statement {
    sid       = replace("${var.serverless-laravel-cicd-name}-uploadToBucket", "-", "")
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.org}-*-${var.serverless-laravel}", ]
  }

  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-configureBucket", "-", "")
    actions = [
      "s3:GetBucketPolicyStatus",
      "s3:PutBucketAcl",
      "s3:PutBucketPolicy",
      "s3:CreateBucket",
      "s3:GetBucketAcl",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "s3:GetBucketPolicy"
    ]
    resources = ["arn:aws:s3:::${var.org}-*-${var.serverless-laravel}"]
  }
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-s3-storage" {
  policy_arn = aws_iam_policy.serverless-laravel-s3-storage.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

resource "aws_iam_policy" "serverless-laravel-s3-storage" {
  name   = "${var.serverless-laravel-cicd-name}ForS3Storage"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-s3-storage.json
}

data "aws_iam_policy_document" "serverless-laravel-cdn" {
  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-cdn", "-", "")
    actions = [
      "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
      "cloudfront:ListCloudFrontOriginAccessIdentities",
      "cloudfront:TagResource",
      "cloudfront:DeleteCloudFrontOriginAccessIdentity",
      "cloudfront:CreateDistributionWithTags",
      "cloudfront:CreateDistribution",
      "cloudfront:CreateInvalidation",
      "cloudfront:CreateCloudFrontOriginAccessIdentity",
      "cloudfront:GetDistribution",
      "cloudfront:GetCloudFrontOriginAccessIdentity",
      "cloudfront:UpdateDistribution",
      "cloudfront:UpdateCloudFrontOriginAccessIdentity",
      "cloudfront:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid       = replace("${var.serverless-laravel-cicd-name}-kms", "-", "")
    actions   = ["kms:DescribeKey", "kms:CreateGrant"]
    resources = ["arn:aws:kms:${var.eu_west_1}:${var.aws_account_id}:key/*"]
  }
}

resource "aws_iam_policy" "serverless-laravel-cdn" {
  name   = "CDNFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-cdn.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-cdn" {
  policy_arn = aws_iam_policy.serverless-laravel-cdn.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "serverless-laravel-api" {
  statement {
    sid = replace("${var.serverless-laravel-cicd-name}-api", "-", "")
    actions = [
      "apigateway:DELETE",
      "apigateway:PUT",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:GET"
    ]
    resources = [ "arn:aws:apigateway:*::*" ]

  }
}

resource "aws_iam_policy" "serverless-laravel-api" {
  name   = "APIFor${var.serverless-laravel-cicd-name}"
  path   = "/${var.serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.serverless-laravel-api.json
}

resource "aws_iam_user_policy_attachment" "serverless-laravel-api" {
  policy_arn = aws_iam_policy.serverless-laravel-api.arn
  user       = aws_iam_user.serverless-laravel-cicd.name
}
