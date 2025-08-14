variable "profile" {
  type        = string
  description = "AWS Profile"
}
variable "env" {
  type        = string
  description = "Environment"
}
variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
}

# Tags
variable "cluster_name" {
  description = "Cluster Name"
  type = string
}
variable "application" {
  description = "Application Name"
  type = string
}
variable "project" {
  description = "Project Name"
  type = string
}
variable "team" {
  description = "Team Name"
  type = string
}
variable "contact" {
  description = "Contact"
  type = string
}
variable "managed_by" {
  description = "Managed By"
  type = string
}

# This VPC ID is being read from the output of VPC module from ./modules/network
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}
variable "aws_region" {
  description = "AWS region"
  type        = string
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

variable "client_encoding" {
  description = "client_encoding setting for parameter group"
  type = string
}

variable "autovacuum" {
  description = "autovacuum setting for parameter group"
  type = string
}
variable "manage_master_user_password" {
  description = "Manage password in Secrets Manager"
  type = bool
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM Auth."
  type = bool
}

# Security group
variable "security_group_desc" {
  description = "Security group for rds."
  type = string
}

variable "db_internal_record_name" {
  description = "Internal Database Record Name."
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet Ids for DB subnet group"
}