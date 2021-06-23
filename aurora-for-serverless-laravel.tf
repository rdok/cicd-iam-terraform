variable "aurora-for-serverless-laravel" {
  default = "aurora-for-serverless-laravel*"
  type    = string
}

variable "aurora-for-serverless-laravel-cicd-name" {
  default = "aurora-for-serverless-laravel-cicd"
  type    = string
}

resource "aws_iam_user" "aurora-for-serverless-laravel-cicd" {
  name = var.aurora-for-serverless-laravel-cicd-name
  tags = {
    Name = var.aurora-for-serverless-laravel-cicd-name
  }
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-global-resources" {
  statement {
    sid     = replace("${var.aurora-for-serverless-laravel-cicd-name}-global", "-", "")
    actions = concat(var.lambda_actions_global, var.sam_validate, var.apigateway_actions_global)
    resources = [
    "*"]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-global" {
  name   = "GlobalAuthFor${var.aurora-for-serverless-laravel-cicd-name}"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-global-resources.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-global" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-global.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel" {
  statement {
    sid = replace(var.aurora-for-serverless-laravel-cicd-name, "-", "")
    actions = concat(
      var.cloudformation_actions, var.iam_sam_actions, var.lambda_actions, var.s3_cicd_actions,
      ["secretsmanager:GetSecretValue"]
    )
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-*-${var.aurora-for-serverless-laravel}/*",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.aurora-for-serverless-laravel}",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-*-${var.aurora-for-serverless-laravel}",
      "arn:aws:secretsmanager:${var.eu_west_1}:${var.aws_account_id}:secret:${var.org}-*-${var.aurora-for-serverless-laravel}",
    ]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel" {
  name   = "AuthFor${var.aurora-for-serverless-laravel-cicd-name}"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-certificate" {
  statement {
    sid     = replace("${var.aurora-for-serverless-laravel-cicd-name}-certificate", "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.aurora-for-serverless-laravel}/*",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.aurora-for-serverless-laravel}",
    ]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-certificate" {
  name   = "AuthFor${var.aurora-for-serverless-laravel-cicd-name}Certificate"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-certificate.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-certificate" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-certificate.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-certificate-gen" {
  statement {
    sid       = replace("${var.aurora-for-serverless-laravel-cicd-name}-request-certificate", "-", "")
    actions   = ["acm:RequestCertificate", "acm:DeleteCertificate", "acm:DescribeCertificate"]
    resources = ["*"]
  }

  statement {
    sid = replace("${var.aurora-for-serverless-laravel-cicd-name}-change-certificate", "-", "")
    actions = [
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:acm:${var.org}-*-${var.aurora-for-serverless-laravel}:${var.aws_account_id}:certificate/*",
      "arn:aws:route53:::hostedzone/${var.base_domain_route_53_hosted_zone_id}",
      "arn:aws:route53:::change/*"
    ]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-certificate-gen" {
  name   = "DomainManagerFor${var.aurora-for-serverless-laravel-cicd-name}CertificateGen"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-certificate-gen.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-certificate-gen" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-certificate-gen.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-s3-storage" {
  statement {
    sid = replace("${var.aurora-for-serverless-laravel-cicd-name}-uploadToBucket", "-", "")
    actions = [
      "s3:PutObject",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["arn:aws:s3:::${var.org}-*-${var.aurora-for-serverless-laravel}", ]
  }

  statement {
    sid = replace("${var.aurora-for-serverless-laravel-cicd-name}-configureBucket", "-", "")
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
    resources = ["arn:aws:s3:::${var.org}-*-${var.aurora-for-serverless-laravel}"]
  }
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-s3-storage" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-s3-storage.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-s3-storage" {
  name   = "${var.aurora-for-serverless-laravel-cicd-name}ForS3Storage"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-s3-storage.json
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-cdn" {
  statement {
    sid = replace("${var.aurora-for-serverless-laravel-cicd-name}-cdn", "-", "")
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
    sid       = replace("${var.aurora-for-serverless-laravel-cicd-name}-kms", "-", "")
    actions   = ["kms:DescribeKey", "kms:CreateGrant"]
    resources = ["arn:aws:kms:${var.eu_west_1}:${var.aws_account_id}:key/*"]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-cdn" {
  name   = "CDNFor${var.aurora-for-serverless-laravel-cicd-name}"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-cdn.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-cdn" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-cdn.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-api" {
  statement {
    sid       = replace("${var.aurora-for-serverless-laravel-cicd-name}-api", "-", "")
    actions   = ["apigateway:*"]
    resources = ["*"]

  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-api" {
  name   = "APIFor${var.aurora-for-serverless-laravel-cicd-name}"
  path   = "/${var.aurora-for-serverless-laravel-cicd-name}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-api.json
}

resource "aws_iam_user_policy_attachment" "aurora-for-serverless-laravel-api" {
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-api.arn
  user       = aws_iam_user.aurora-for-serverless-laravel-cicd.name
}
