output "repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repo URL (push/pull)"
}

output "repository_arn" {
  value       = module.ecr.repository_arn
  description = "ECR repository ARN"
}

output "kms_key_arn" {
  value       = local.effective_kms_key_arn
  description = "KMS key ARN used for encryption (null if AES256)"
}
