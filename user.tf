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
    sid     = "AllowAssumeRole"
    actions = ["sts:AssumeRole"]
    //    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.org}/*"]
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
}

variable "cicd-name" {
  default = "cicd-os"
  type    = string
}
