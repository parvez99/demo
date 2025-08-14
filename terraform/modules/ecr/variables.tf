variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "ECR tag mutability"
  type        = string
  default     = "MUTABLE" # or "IMMUTABLE"
}

variable "image_scan_on_push" {
  description = "Enable ECR vulnerability scans on push"
  type        = bool
  default     = true
}

variable "enable_kms_encryption" {
  description = "Use KMS encryption at rest (otherwise AWS-managed AES256)"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Create a new KMS CMK for ECR"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use when create_kms_key=false"
  type        = string
  default     = null
}

variable "kms_key_alias" {
  description = "Alias for the created KMS key (only used when create_kms_key=true)"
  type        = string
  default     = "alias/ecr-repo"
}

variable "read_write_access_arns" {
  description = "IAM principals (roles/users) with push/pull permissions"
  type        = list(string)
  default     = []
}

variable "pull_access_arns" {
  description = "IAM principals (roles/users) with pull-only permissions"
  type        = list(string)
  default     = []
}

variable "create_lifecycle_policy" {
  description = "Create lifecycle policy"
  type        = bool
  default     = true
}

variable "expire_untagged_after_days" {
  description = "Expire untagged images after N days"
  type        = number
  default     = 7
}

variable "keep_last_tagged" {
  description = "Keep the last N images per tag; older ones expire"
  type        = number
  default     = 10
}

variable "force_delete" {
  description = "Force delete repository on destroy (dev convenience)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
