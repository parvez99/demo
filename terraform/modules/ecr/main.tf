# Optional CMK for ECR
resource "aws_kms_key" "ecr" {
  count               = var.enable_kms_encryption && var.create_kms_key ? 1 : 0
  description         = "KMS key for ECR: ${var.repository_name}"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "ecr" {
  count         = var.enable_kms_encryption && var.create_kms_key ? 1 : 0
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.ecr[0].key_id
}

locals {
  effective_kms_key_arn = var.enable_kms_encryption ? (
  var.create_kms_key ? aws_kms_key.ecr[0].arn : var.kms_key_arn
  ) : null

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged after ${var.expire_untagged_after_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.expire_untagged_after_days
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.keep_last_tagged} per tag"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = [""]
          countType     = "imageCountMoreThan"
          countNumber   = var.keep_last_tagged
        }
        action = { type = "expire" }
      }
    ]
  })
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.0"

  repository_name                 = var.repository_name
  repository_image_tag_mutability = var.image_tag_mutability

  # Encryption (omit when null → AES256 by AWS-managed key)
  repository_encryption_type   = "KMS"
  repository_kms_key = local.effective_kms_key_arn

  # Scanning
  repository_image_scan_on_push = var.image_scan_on_push

  # Access
  repository_read_write_access_arns = var.read_write_access_arns

  # Lifecycle
  create_lifecycle_policy   = var.create_lifecycle_policy
  repository_lifecycle_policy = var.create_lifecycle_policy ? local.lifecycle_policy : null

  repository_force_delete = var.force_delete

  tags = var.tags
}
