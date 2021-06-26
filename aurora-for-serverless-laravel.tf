variable "aurora-for-serverless-laravel" {
  default = "aurora-for-serverless-laravel"
  type    = string
}

resource "aws_iam_role" "aurora-for-serverless-laravel" {
  name               = var.aurora-for-serverless-laravel
  tags               = { Name = var.aurora-for-serverless-laravel }
  path               = "/${var.org}/"
  assume_role_policy = data.aws_iam_policy_document.cicd-allow--trusted-identifiers.json
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-global" {
  statement {
    sid       = replace("${var.aurora-for-serverless-laravel}-global", "-", "")
    actions   = concat(var.lambda_actions_global, var.sam_validate_global, var.apigateway_actions_global)
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-global" {
  name   = "${var.aurora-for-serverless-laravel}-global"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-global.json
}

resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-global" {
  role       = aws_iam_role.aurora-for-serverless-laravel.name
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-global.arn
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel" {
  statement {
    sid = replace(var.aurora-for-serverless-laravel, "-", "")
    actions = concat(
      var.cloudformation_actions, var.iam_sam_actions, var.lambda_actions, var.s3_cicd_actions,
      ["secretsmanager:GetSecretValue"]
    )
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-*-${var.aurora-for-serverless-laravel}*/*",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.aurora-for-serverless-laravel}*",
      "arn:aws:lambda:${var.eu_west_1}:${var.aws_account_id}:function:${var.org}-*-${var.aurora-for-serverless-laravel}*",
      "arn:aws:secretsmanager:${var.eu_west_1}:${var.aws_account_id}:secret:${var.org}-*-${var.aurora-for-serverless-laravel}*",
    ]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel" {
  name   = "${var.aurora-for-serverless-laravel}-main"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel.json
}

resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-main" {
  role       = aws_iam_role.aurora-for-serverless-laravel.name
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel.arn
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-certificate" {
  statement {
    sid       = replace("${var.aurora-for-serverless-laravel}-certificate-global", "-", "")
    actions   = concat(var.lambda_actions_global, var.sam_validate_global, var.apigateway_actions_global)
    resources = ["*"]
  }
  statement {
    sid     = replace("${var.aurora-for-serverless-laravel}-certificate", "-", "")
    actions = concat(var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.aurora-for-serverless-laravel}*/*",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/*",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.aurora-for-serverless-laravel}*",
    ]
  }
}

resource "aws_iam_policy" "aurora-for-serverless-laravel-certificate" {
  name   = "${var.aurora-for-serverless-laravel}-certificate"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-certificate.json
}

resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-certificate-global" {
  role       = aws_iam_role.aurora-for-serverless-laravel.name
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-certificate.arn
}

data "aws_iam_policy_document" "aurora-for-serverless-laravel-certificate-domain" {
  statement {
    sid       = replace("${var.aurora-for-serverless-laravel}-certificate-domain", "-", "")
    actions   = ["acm:RequestCertificate", "acm:DeleteCertificate", "acm:DescribeCertificate"]
    resources = ["*"]
  }

  statement {
    sid = replace("${var.aurora-for-serverless-laravel}-change-certificate", "-", "")
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

resource "aws_iam_policy" "aurora-for-serverless-laravel-certificate-domain" {
  name   = "${var.aurora-for-serverless-laravel}-certificate-domain"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-certificate-domain.json
}

resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-certificate-domain" {
  role       = aws_iam_role.aurora-for-serverless-laravel.name
  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-certificate-domain.arn
}

//data "aws_iam_policy_document" "aurora-for-serverless-laravel-s3-storage" {
//  statement {
//    sid = replace("${var.aurora-for-serverless-laravel}-uploadToBucket", "-", "")
//    actions = [
//      "s3:PutObject",
//      "s3:ListBucketVersions",
//      "s3:ListBucket",
//      "s3:DeleteObject",
//      "s3:ListMultipartUploadParts"
//    ]
//    resources = ["arn:aws:s3:::${var.org}-*-${var.aurora-for-serverless-laravel}*", ]
//  }
//
//  statement {
//    sid = replace("${var.aurora-for-serverless-laravel}-configureBucket", "-", "")
//    actions = [
//      "s3:GetBucketPolicyStatus",
//      "s3:PutBucketAcl",
//      "s3:PutBucketPolicy",
//      "s3:CreateBucket",
//      "s3:GetBucketAcl",
//      "s3:DeleteBucketPolicy",
//      "s3:DeleteBucket",
//      "s3:GetBucketPolicy"
//    ]
//    resources = ["arn:aws:s3:::${var.org}-*-${var.aurora-for-serverless-laravel}*"]
//  }
//}
//
//resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-s3-storage" {
//  role       = aws_iam_role.aurora-for-serverless-laravel.name
//  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-s3-storage.arn
//}
//
//resource "aws_iam_policy" "aurora-for-serverless-laravel-s3-storage" {
//  name   = "${var.aurora-for-serverless-laravel}ForS3Storage"
//path   = "/${var.org}/"
//  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-s3-storage.json
//}
//
//data "aws_iam_policy_document" "aurora-for-serverless-laravel-cdn" {
//  statement {
//    sid = replace("${var.aurora-for-serverless-laravel}-cdn", "-", "")
//    actions = [
//      "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
//      "cloudfront:ListCloudFrontOriginAccessIdentities",
//      "cloudfront:TagResource",
//      "cloudfront:DeleteCloudFrontOriginAccessIdentity",
//      "cloudfront:CreateDistributionWithTags",
//      "cloudfront:CreateDistribution",
//      "cloudfront:CreateInvalidation",
//      "cloudfront:CreateCloudFrontOriginAccessIdentity",
//      "cloudfront:GetDistribution",
//      "cloudfront:GetCloudFrontOriginAccessIdentity",
//      "cloudfront:UpdateDistribution",
//      "cloudfront:UpdateCloudFrontOriginAccessIdentity",
//      "cloudfront:UntagResource"
//    ]
//    resources = ["*"]
//  }
//
//  statement {
//    sid       = replace("${var.aurora-for-serverless-laravel}-kms", "-", "")
//    actions   = ["kms:DescribeKey", "kms:CreateGrant"]
//    resources = ["arn:aws:kms:${var.eu_west_1}:${var.aws_account_id}:key/*"]
//  }
//}
//
//resource "aws_iam_policy" "aurora-for-serverless-laravel-cdn" {
//  name   = "CDNFor${var.aurora-for-serverless-laravel}*"
//path   = "/${var.org}/"
//  policy = data.aws_iam_policy_document.aurora-for-serverless-laravel-cdn.json
//}
//
//resource "aws_iam_role_policy_attachment" "aurora-for-serverless-laravel-cdn" {
//  role       = aws_iam_role.aurora-for-serverless-laravel.name
//  policy_arn = aws_iam_policy.aurora-for-serverless-laravel-cdn.arn
//}
