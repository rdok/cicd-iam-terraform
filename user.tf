resource "aws_iam_user" "cicd-os" {
  name = var.cicd-name
  tags = {
    Name        = var.cicd-name,
    Description = "Common CI/CD user for many repositories."
  }
}

resource "aws_iam_user_policy" "cicd-allow-assume-role" {
  user   = aws_iam_user.cicd-os.name
  policy = data.aws_iam_policy_document.cicd-allow-assume-role.json
}

data "aws_iam_policy_document" "cicd-allow-assume-role" {
  statement {
    sid       = "AllowAssumeRole"
    actions   = ["sts:AssumeRole", "iam:PassRole"]
    resources = [aws_iam_role.aurora-for-serverless-laravel.arn]
  }
}

data "aws_iam_policy_document" "cicd-allow--trusted-identifiers" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.cicd-os.arn]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }
  }
}

variable "cicd-name" {
  default = "cicd-os"
  type    = string
}

resource "aws_iam_policy" "cicd-bucket" {
  name   = "${var.cicd-name}-bucket"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.cicd-bucket.json
}
resource "aws_iam_user_policy_attachment" "cicd-bucket" {
  policy_arn = aws_iam_policy.cicd-bucket.arn
  user       = aws_iam_user.cicd-os.name
}

data "aws_iam_policy_document" "cicd-bucket" {
  statement {
    sid     = replace("${var.cicd-name}-deploy-bucket", "-", "")
    actions = concat(var.cloudformation_actions, var.s3_cicd_actions)
    resources = [
      "arn:aws:cloudformation:${var.us_east_1}:${var.aws_account_id}:stack/${var.org}-*-${var.serverless-laravel}/*",
      "arn:aws:cloudformation:${var.us_east_1}:aws:transform/Serverless-2016-10-31",
      "arn:aws:s3:::${aws_s3_bucket.prod-cicd-us-east-1.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.test-cicd-us-east-1.bucket}/*",
    ]
  }
}
