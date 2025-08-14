# This file allows sharing of values between modules.
data "aws_region" "current" {}

provider "aws" {
  region = var.aws_region
  profile = "kpersonal"
  allowed_account_ids = var.allowed_account_ids
}

module "vpc" {
  source = "../../modules/network"
  aws_region = var.aws_region
  clusterName = var.clusterName
  vpc_cidr = var.vpc_cidr
  env = var.env
  projectName = var.projectName
  applicationName = var.applicationName
  azs = var.azs
  private_subnets = var.private_subnets
  private_subnet_prefix = var.private_subnet_prefix
  public_subnet_prefix = var.public_subnet_prefix
  public_subnets = var.public_subnets
  single_nat_gateway = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_nat_gateway = var.enable_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  vpc_id = module.vpc.vpc_id
  igw_id = module.vpc.igw_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets

  private_subnet_prefix = var.private_subnet_prefix
  aws_region = var.aws_region
  vpc_cidr = var.vpc_cidr
  coredns_addon_version = var.coredns_addon_version
  kubeproxy_addon_version = var.kubeproxy_addon_version
  azs = var.azs
  clusterName = var.clusterName
  cluster_version = var.cluster_version
  env = var.env
  projectName = var.projectName
  applicationName = var.applicationName
  iam_role_name = var.iam_role_name
  instance_type = var.instance_type
  volume_size = var.volume_size
  volume_type = var.volume_type
  control_plane_subnets = var.control_plane_subnets
  control_plane_subnet_prefix = var.control_plane_subnet_prefix
  self_managed_ng_name = var.self_managed_ng_name
  cni_addon_version = var.cni_addon_version
  launch_template_name = var.launch_template_name
  min_size = var.min_size
  max_size = var.max_size
  desired_size = var.desired_size
  vpc_cni_role_iam_arn = var.vpc_cni_role_iam_arn
  vpc_cni_enable_np = var.vpc_cni_enable_np
}

module "ecr_pmulani_api" {
  source = "../../modules/ecr"

  repository_name         = var.repository_name
  image_tag_mutability    = var.image_tag_mutability
  image_scan_on_push      = var.image_scan_on_push

  enable_kms_encryption   = var.enable_kms_encryption
  create_kms_key          = var.create_kms_key
  kms_key_alias           = var.kms_key_alias

  read_write_access_arns  = var.ecr_push_arns   # CI/CD role(s)
  pull_access_arns        = var.ecr_pull_arns   # optional

  create_lifecycle_policy = var.create_lifecycle_policy
  expire_untagged_after_days = var.expire_untagged_after_days
  keep_last_tagged        = var.keep_last_tagged

  force_delete            = var.force_delete

  tags = {
    Project     = var.projectName
    Environment = var.applicationName
  }
}

module "rds" {
  source   = "../../modules/rds"
  aws_region  = var.aws_region
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  db_instancename = var.db_instancename
  profile = var.profile
  allowed_account_ids = var.allowed_account_ids
  application = var.applicationName
  project = var.projectName
  env = var.env
  managed_by = var.managed_by
  team = var.team
  contact = var.contact
  db_engine = var.db_engine
  db_engine_version = var.db_engine_version
  db_engine_lifecycle_support = var.db_engine_lifecycle_support
  db_parameter_group = var.db_parameter_group
  db_major_engine_version = var.db_major_engine_version
  db_instance_class = var.db_instance_class
  db_storage_type = var.db_storage_type
  db_instance_allocated_storage = var.db_instance_allocated_storage
  db_instance_max_allocated_storage = var.db_instance_max_allocated_storage
  db_name = var.db_name
  db_username = var.db_username
  db_port = var.db_port
  maintenance_window = var.maintenance_window
  subnet_ids = module.vpc.private_subnets
  multi_az = var.multi_az
  db_subnet_group_name = var.db_subnet_group_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  create_monitoring_role = var.create_monitoring_role
  monitoring_interval = var.monitoring_interval
  monitoring_role_description = var.monitoring_role_description
  monitoring_role_name = var.monitoring_role_name
  monitoring_role_use_name_prefix = var.monitoring_role_use_name_prefix
  backup_window = var.backup_window
  manage_master_user_password = var.manage_master_user_password
  security_group_desc = var.security_group_desc
  autovacuum = var.autovacuum
  client_encoding = var.client_encoding
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  db_internal_record_name = var.db_internal_record_name
}