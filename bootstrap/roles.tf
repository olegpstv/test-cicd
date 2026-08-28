locals {
  oidc_provider = aws_iam_openid_connect_provider.github.arn
  oidc_host     = "token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "push_trust" {
  statement {
    effect  = "allow"
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
    effect  = "allow"
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