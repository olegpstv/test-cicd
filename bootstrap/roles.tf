locals {
  oidc_provider = aws_iam_openid_connect_provider.github.arn
  oidc_host     = "token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "push_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "push" {
  name               = "${var.prefix}-gha-push"
  assume_role_policy = data.aws_iam_policy_document.push_trust.json
}

data "aws_iam_policy_document" "apply_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["repo:${var.github_repo}:environment:prod"]
    }
  }
}

resource "aws_iam_role" "apply" {
  name               = "${var.prefix}-gha-apply"
  assume_role_policy = data.aws_iam_policy_document.apply_trust.json
}

data "aws_iam_policy_document" "push_permissions" {
  statement {
    sid = "GetAuthToken"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PushToRepo"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_role_policy" "push" {
  name = "${var.prefix}-gha-push"
  policy = data.aws_iam_policy_document.push_permissions.json
  role   = aws_iam_role.push.id
}

data "aws_iam_policy_document" "apply_permissions" {
  statement {
    sid    = "TerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.tfstate.arn,
      "${aws_s3_bucket.tfstate.arn}/*",
    ]
  }

  statement {
    sid    = "StackResources"
    effect = "Allow"
    actions = [
      "ec2:*",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:PassRole",
      "iam:TagRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "ssm:GetParameter",
      "ecr:DescribeRepositories",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "apply" {
  name   = "${var.prefix}-gha-apply"
  role   = aws_iam_role.apply.name
  policy = data.aws_iam_policy_document.apply_permissions.json
}