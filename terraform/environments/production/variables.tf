variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = ["832850273244"]
}

variable "profile" {
  type        = string
  description = "AWS Profile"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = "eu-west-1"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}
variable "clusterName" {
  type        = string
  description = "Cluster Name"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes control plane version."
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "projectName" {
  type        = string
  description = "Project Name"
}

variable "applicationName" {
  type        = string
  description = "Application Name"
}

# Tags
variable "cluster_name" {
  description = "Cluster Name"
  type = string
  default = "pmulani-prod-eks-eu-west-1"
}

variable "team" {
  description = "Team Name"
  type = string
  default = "MyTeam"
}
variable "contact" {
  description = "Contact"
  type = string
  default = "myteam@gmail.com"
}
variable "managed_by" {
  description = "Managed By"
  type = string
  default = "terraform"
}

variable "backend_bucket" {
  type        = string
  description = "Backend bucket"
}

variable "backend_bucket_key" {
  type        = string
  description = "Backend bucket Key"
}

variable "coredns_addon_version" {
  type        = string
  description = "Core DNS addon version"
}


variable "self_managed_ng_name" {
  type        = string
  description = "Self managed node group"
}

variable "cni_addon_version" {
  type        = string
  description = "CNI Version"
}

variable "vpc_cni_role_iam_arn" {
  type        = string
  description = "VPC CNI IAM"
}
variable "vpc_cni_enable_np" {
  type        = string
  description = "Enable vpc cni network policy support"
}

variable "kubeproxy_addon_version" {
  type        = string
  description = "Kube Proxy Version"
}

# EC2 #
variable "instance_type" {
  type        = string
  description = "Default instance type"
}

#LT
variable "launch_template_name" {
  type        = string
  description = "Launch template name"
}
#Volume
variable "volume_size" {
  type        = number
  description = "Volume size of staging ec2 nodes"
}
variable "volume_type" {
  type        = string
  description = "EBS volume type of ec2 nodes"
}

#IAM
variable "iam_role_name" {
  type        = string
  description = "IAM role for ec2 instances"
}


# Network #
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}
variable "azs" {
  type        = list(string)
  description = "AZs for subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets per AZ"
}

variable "control_plane_subnets" {
  type        = list(string)
  description = "Control plane subnets per AZ"
}

variable "control_plane_subnet_prefix" {
  type        = list(string)
  description = "Control plane subnet name prefix"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet per AZ"
}

variable "private_subnet_prefix" {
  type        = list(string)
  description = "Private subnet name prefix"
}

variable "public_subnet_prefix" {
  type        = list(string)
  description = "Public subnet name prefix"
}
variable "node_security_group_tags" {
  description = "Additional tags for the node security groups"
  type        = map(string)
  default     = {}
}

variable "igw_id" {
  description = "The ID of the IG"
  type        = string
  default     = "us-east-1"
}

variable "min_size" {
  type        = number
  description = "Min ec2 instances"
  #default     = 3
}
variable "max_size" {
  type        = number
  description = "Max ec2 instances"
  #default     = 5
}
variable "desired_size" {
  type        = number
  description = "Desired number of ec2 instances"
  #default     = 2
}

variable "single_nat_gateway" {
  type        = bool
  description = "Environment"
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Environment"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Environment"
}

#DB
variable "db_port" {
  description = "DB Port Number"
  type        = string
}
variable "db_instancename" {
  description = "DB instance name"
  type        = string
}

variable "db_engine" {
  description = "DB Engine"
  type = string
}

variable "db_engine_version" {
  description = "DB Engine Version"
  type = string
}

variable "db_engine_lifecycle_support" {
  description = "DB Engine Lifecycle Support"
  type = string
}

variable "db_parameter_group" {
  description = "DB Parameter Group"
  type = string
}

variable "db_major_engine_version" {
  description = "DB Major Engine Version"
  type = string
}

variable "db_instance_class" {
  description = "DB Instance Class"
  type = string
}

variable "db_instance_allocated_storage" {
  description = "DB Instance Allocated Storage"
  type = string
}

variable "db_instance_max_allocated_storage" {
  description = "DB Instance Max Allocated Storage"
  type = string
}
variable "db_storage_type" {
  description = "DB Storage Type"
  type = string
}

variable "db_name" {
  description = "DB Name"
  type = string
}

variable "db_username" {
  description = "DB Username"
  type = string
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  type = string
}
variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type = bool
}

variable "multi_az" {
  description = "Multi AZ"
  type = bool
}

variable "maintenance_window" {
  description = "Maintenance Window"
  type = string
}

variable "backup_window" {
  description = "Backup Window"
  type = string
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "Logs to enable"
}

variable "create_cloudwatch_log_group" {
  description = "Create Cloudwatch Group"
  type = bool
}

variable "backup_retention_period" {
  description = "Backup Retention Period"
  type = string
}

variable "skip_final_snapshot" {
  description = "Skip Final Snapshot"
  type = bool
}

variable "deletion_protection" {
  description = "Delete Protection"
  type = bool
}

variable "performance_insights_enabled" {
  description = "Performance Insights"
  type = bool
}

variable "performance_insights_retention_period" {
  description = "Performance Insights Retention"
  type = string
}

variable "create_monitoring_role" {
  description = "Monitoring Role"
  type = bool
}

variable "monitoring_interval" {
  description = "Monitoring Interval"
  type = string
}

variable "monitoring_role_name" {
  description = "Monitoring Role Name"
  type = string
}
variable "monitoring_role_use_name_prefix" {
  description = "Monitoring Role Prefix"
  type = bool
}
variable "monitoring_role_description" {
  description = "Monitoring Role Desc"
  type = string
}
variable "manage_master_user_password" {
  description = "Manage password in Secrets Manager"
  type = bool
}

variable "autovacuum" {
  description = "autovacuum setting for parameter group"
  type = string
}
variable "client_encoding" {
  description = "client_encoding setting for parameter group"
  type = string
}

variable "security_group_desc" {
  description = "Security group for rds."
  type = string
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM Auth."
  type = bool
}

variable "db_internal_record_name" {
  description = "Internal Database Record Name."
  type = string
}

# ECR

variable "ecr_push_arns" {
  description = "Principals allowed to push/pull"
  type        = list(string)
  default     = []
}

variable "ecr_pull_arns" {
  description = "Principals allowed to pull"
  type        = list(string)
  default     = []
}
variable "repository_name" {
  description = "ECR repository name (no slash)"
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
  description = "Common tags"
  type        = map(string)
  default     = {}
}
