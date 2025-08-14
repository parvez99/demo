provider "aws" {
  region = var.aws_region
  profile = var.profile
  allowed_account_ids = var.allowed_account_ids
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name      = var.db_instancename
  region = var.aws_region

  vpc_cidr = var.vpc_cidr

  tags = {
    Name        = local.name
    Application = var.application
    Project     = var.project
    Cluster     = var.cluster_name
    Environment = var.env
    ManagedBy   = var.managed_by
    Team        = var.team
    Contact     = var.contact
  }
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                   = var.db_engine
  engine_version           = var.db_engine_version
  engine_lifecycle_support = var.db_engine_lifecycle_support
  family                   = var.db_parameter_group # DB parameter group
  major_engine_version     = var.db_major_engine_version       # DB option group
  instance_class           = var.db_instance_class
  storage_type             = var.db_storage_type
  allocated_storage     = var.db_instance_allocated_storage
  max_allocated_storage = var.db_instance_max_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  manage_master_user_password = var.manage_master_user_password
  manage_master_user_password_rotation              = false
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(365 days)"

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = var.maintenance_window
  backup_window                   = var.backup_window
  backup_retention_period         = var.backup_retention_period

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group

  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  create_monitoring_role                = var.create_monitoring_role
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_name                  = var.monitoring_role_name
  monitoring_role_use_name_prefix       = var.monitoring_role_use_name_prefix
  monitoring_role_description           = var.monitoring_role_description

  parameters = [
    {
      name  = "autovacuum"
      value = var.autovacuum
    },
    {
      name  = "client_encoding"
      value = var.client_encoding
    },
    {
      name  = "client_encoding"
      value = var.client_encoding
    },
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}

################################################################################
# Supporting Resources
################################################################################



module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = var.security_group_desc
  vpc_id                   = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = local.tags
}

resource "aws_route53_zone" "internal_dns_zone" {
  name = "${var.cluster_name}.aws.internal"

  vpc {
    vpc_id = var.vpc_id
  }
  tags = local.tags
  depends_on = [module.db]
}

resource "aws_route53_record" "database_record" {
  zone_id = "${aws_route53_zone.internal_dns_zone.zone_id}"
  name = "${var.db_internal_record_name}"
  type = "CNAME"
  ttl = "300"
  records = [module.db.db_instance_address]
  depends_on = [aws_route53_zone.internal_dns_zone]
}