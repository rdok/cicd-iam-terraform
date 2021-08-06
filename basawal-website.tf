variable "basawal-website" {
  default = "basawal-website"
  type    = string
  description = "'basawal' stands for Build a Serverless App with AWS Lambda, and is used for kata."
}

variable "basawal-web-app-stack-locator" {
  default     = "basawal-web-app*"
  description = "The AWS SAM shortened stack name."
  type        = string
}

resource "aws_iam_role" "basawal-web-app" {
  name               = var.basawal-website
  description        = "The role which the CD will assume."
  tags               = { Name = var.basawal-website }
  path               = "/${var.org}/"
  assume_role_policy = data.aws_iam_policy_document.cicd-allow--trusted-identifiers.json
}

data "aws_iam_policy_document" "basawal-web-app-global" {
  statement {
    sid = replace("${var.basawal-website}-global", "-", "")
    actions = concat(
      var.sam_validate_global, var.describe_actions_global,
      var.cloudformation_actions_global
    )
    resources = ["*"]
  }
}

resource "aws_iam_policy" "basawal-web-app-global" {
  name   = "${var.basawal-website}-global"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app-global.json
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-global" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app-global.arn
}

data "aws_iam_policy_document" "basawal-web-app" {
  statement {
    sid = replace(var.basawal-website, "-", "")
    actions = concat(
      var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions
    )
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-*-${var.basawal-web-app-stack-locator}",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/${var.basawal-web-app-stack-locator}",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/${var.basawal-web-app-stack-locator}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.basawal-web-app-stack-locator}",
    ]
  }
}

resource "aws_iam_policy" "basawal-web-app" {
  name   = "${var.basawal-website}-main"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app.json
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-main" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app.arn
}

data "aws_iam_policy_document" "basawal-web-app-certificate" {
  statement {
    sid = replace("${var.basawal-website}-certificate-global", "-", "")
    actions = concat(
      var.sam_validate_global, var.apigateway_actions_global
    )
    resources = ["*"]
  }
  statement {
    sid = replace("${var.basawal-website}-certificate", "-", "")
    actions = concat(
      var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions
    )
    resources = [
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.basawal-web-app-stack-locator}",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/${var.basawal-web-app-stack-locator}",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/${var.basawal-web-app-stack-locator}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.basawal-web-app-stack-locator}",
    ]
  }
}

resource "aws_iam_policy" "basawal-web-app-certificate" {
  name   = "${var.basawal-website}-certificate"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app-certificate.json
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-certificate-global" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app-certificate.arn
}

data "aws_iam_policy_document" "basawal-web-app-certificate-domain" {
  statement {
    sid = replace("${var.basawal-website}-certificate-domain", "-", "")
    actions = [
      "acm:RequestCertificate", "acm:DeleteCertificate",
      "acm:DescribeCertificate"
    ]
    resources = ["*"]
  }

  statement {
    sid = replace("${var.basawal-website}-change-certificate", "-", "")
    actions = [
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:acm:${var.org}-*-${var.basawal-website}:${var.aws_account_id}:certificate/*",
      "arn:aws:route53:::hostedzone/${var.base_domain_route_53_hosted_zone_id}",
      "arn:aws:route53:::change/*"
    ]
  }
}

resource "aws_iam_policy" "basawal-web-app-certificate-domain" {
  name   = "${var.basawal-website}-certificate-domain"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app-certificate-domain.json
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-certificate-domain" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app-certificate-domain.arn
}

data "aws_iam_policy_document" "basawal-web-app-s3" {
  statement {
    sid = replace("${var.basawal-website}-uploadToBucket", "-", "")
    actions = [
      "s3:PutObject", "s3:ListBucketVersions", "s3:ListBucket",
      "s3:DeleteObject", "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${var.org}-*-${var.basawal-web-app-stack-locator}",
    ]
  }

  statement {
    sid = replace("${var.basawal-website}-configureBucket", "-", "")
    actions = [
      "s3:GetBucketPolicyStatus", "s3:PutBucketAcl", "s3:PutBucketPolicy",
      "s3:CreateBucket", "s3:GetBucketAcl", "s3:DeleteBucketPolicy",
      "s3:DeleteBucket", "s3:GetBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::${var.org}-*-${var.basawal-web-app-stack-locator}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-s3" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app-s3.arn
}

resource "aws_iam_policy" "basawal-web-app-s3" {
  name   = "${var.basawal-website}-s3"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app-s3.json
}

data "aws_iam_policy_document" "basawal-web-app-cdn" {
  statement {
    sid = replace("${var.basawal-website}-cdn", "-", "")
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
      "cloudfront:UntagResource",
      "cloudfront:DeleteDistribution"
    ]
    resources = ["*"]
  }

  statement {
    sid     = replace("${var.basawal-website}-kms", "-", "")
    actions = ["kms:DescribeKey", "kms:CreateGrant"]
    resources = [
      "arn:aws:kms:${var.eu_west_1}:${var.aws_account_id}:key/*"
    ]
  }
}

resource "aws_iam_policy" "basawal-web-app-cdn" {
  name   = "CDNFor${var.basawal-website}"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-web-app-cdn.json
}

resource "aws_iam_role_policy_attachment" "basawal-web-app-cdn" {
  role       = aws_iam_role.basawal-web-app.name
  policy_arn = aws_iam_policy.basawal-web-app-cdn.arn
}
