output "push_role_arn" {
  value = aws_iam_role.push.arn
}

output "apply_role_arn" {
  value = aws_iam_role.apply.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.id
}
