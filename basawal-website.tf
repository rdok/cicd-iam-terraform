variable "basawal-website" {
  default = "basawal-website"
  type    = string
  description = "'basawal' stands for Build a Serverless App with AWS Lambda, and is used for kata."
}

variable "basawal-website-stack-locator" {
  default     = "basawal-website*"
  description = "The AWS SAM shortened stack name."
  type        = string
}

resource "aws_iam_role" "basawal-website" {
  name               = var.basawal-website
  description        = "The role which the CD will assume."
  tags               = { Name = var.basawal-website }
  path               = "/${var.org}/"
  assume_role_policy = data.aws_iam_policy_document.cicd-allow--trusted-identifiers.json
}

data "aws_iam_policy_document" "basawal-website-global" {
  statement {
    sid = replace("${var.basawal-website}-global", "-", "")
    actions = concat(
      var.sam_validate_global, var.describe_actions_global,
      var.cloudformation_actions_global
    )
    resources = ["*"]
  }
}

resource "aws_iam_policy" "basawal-website-global" {
  name   = "${var.basawal-website}-global"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website-global.json
}

resource "aws_iam_role_policy_attachment" "basawal-website-global" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website-global.arn
}

data "aws_iam_policy_document" "basawal-website" {
  statement {
    sid = replace(var.basawal-website, "-", "")
    actions = concat(
      var.cloudformation_actions, var.iam_sam_actions, var.s3_cicd_actions
    )
    resources = [
      "arn:aws:cloudformation:${var.eu_west_1}:${var.aws_account_id}:stack/${var.org}-*-${var.basawal-website-stack-locator}",
      "arn:aws:cloudformation:${var.eu_west_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-eu-west-1.bucket}/${var.basawal-website-stack-locator}",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-eu-west-1.bucket}/${var.basawal-website-stack-locator}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.basawal-website-stack-locator}",
    ]
  }
}

resource "aws_iam_policy" "basawal-website" {
  name   = "${var.basawal-website}-main"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website.json
}

resource "aws_iam_role_policy_attachment" "basawal-website-main" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website.arn
}

data "aws_iam_policy_document" "basawal-website-certificate" {
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
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.basawal-website-stack-locator}",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/${var.basawal-website-stack-locator}",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/${var.basawal-website-stack-locator}",
      "arn:aws:iam::${var.aws_account_id}:role/${var.org}-*-${var.basawal-website-stack-locator}",
    ]
  }
}

resource "aws_iam_policy" "basawal-website-certificate" {
  name   = "${var.basawal-website}-certificate"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website-certificate.json
}

resource "aws_iam_role_policy_attachment" "basawal-website-certificate-global" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website-certificate.arn
}

data "aws_iam_policy_document" "basawal-website-certificate-domain" {
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

resource "aws_iam_policy" "basawal-website-certificate-domain" {
  name   = "${var.basawal-website}-certificate-domain"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website-certificate-domain.json
}

resource "aws_iam_role_policy_attachment" "basawal-website-certificate-domain" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website-certificate-domain.arn
}

data "aws_iam_policy_document" "basawal-website-s3" {
  statement {
    sid = replace("${var.basawal-website}-uploadToBucket", "-", "")
    actions = [
      "s3:PutObject", "s3:ListBucketVersions", "s3:ListBucket",
      "s3:DeleteObject", "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${var.org}-*-${var.basawal-website-stack-locator}",
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
      "arn:aws:s3:::${var.org}-*-${var.basawal-website-stack-locator}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "basawal-website-s3" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website-s3.arn
}

resource "aws_iam_policy" "basawal-website-s3" {
  name   = "${var.basawal-website}-s3"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website-s3.json
}

data "aws_iam_policy_document" "basawal-website-cdn" {
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
      "cloudfront:DeleteDistribution",
      "cloudfront:ListTagsForResource",
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

resource "aws_iam_policy" "basawal-website-cdn" {
  name   = "${var.basawal-website}-cdn"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.basawal-website-cdn.json
}

resource "aws_iam_role_policy_attachment" "basawal-website-cdn" {
  role       = aws_iam_role.basawal-website.name
  policy_arn = aws_iam_policy.basawal-website-cdn.arn
}
