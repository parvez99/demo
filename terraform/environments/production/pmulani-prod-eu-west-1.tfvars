#Region
aws_region = "eu-west-1"
azs = ["eu-west-1a","eu-west-1b"]
profile = "kpersonal"
#backend
backend_bucket = "pmulani-prod-tf-backend"
backend_bucket_key = "state/pmulani-prod-eks-eu-west-1.tfstate"

#Cluster : <productname-env-provider-region>
clusterName = "pmulani-prod-eks-eu-west-1"
cluster_version = "1.33"
env = "prod"
projectName = "pmulani"
applicationName = "api"

#VPC
vpc_cidr = "10.100.0.0/16"
control_plane_subnets = ["10.100.0.0/27", "10.100.0.32/27", "10.100.0.64/27"]
control_plane_subnet_prefix = ["pmulani-prod-cntrl-1", "pmulani-prod-cntrl-2", "pmulani-prod-cntrl-3"]
public_subnets = ["10.100.48.0/20", "10.100.64.0/20"]
private_subnets = ["10.100.16.0/20", "10.100.32.0/20"]
private_subnet_prefix = ["pmulani-prod-priv-1", "pmulani-prod-priv-2"]
public_subnet_prefix = ["pmulani-prod-pub-1", "pmulani-prod-pub-2"]


#NAT
single_nat_gateway = true
one_nat_gateway_per_az = false
enable_nat_gateway = true

#EC2
self_managed_ng_name = "pmulani-prod-eks-eu-west-1"
instance_type = "t3a.medium"
launch_template_name = "pmulani-prod-eks-eu-west-1-lt"
volume_size = 100
volume_type = "gp3"
iam_role_name = "pmulani-prod-eks-eu-west-1-iam-role"
coredns_addon_version    = "v1.12.2-eksbuild.4"
cni_addon_version        = "v1.19.6-eksbuild.7"
vpc_cni_role_iam_arn = "arn:aws:iam::832850273244:role/pmulani-prod-eks-eu-west-1-vpc-cni-role"
vpc_cni_enable_np = "true"
kubeproxy_addon_version  = "v1.33.0-eksbuild.2"

max_size = 3
min_size = 2
desired_size = 2

team = "MyTeam"
contact = "myteam@gmail.com"
managed_by = "terraform"

# ECR
repository_name = "pmulani-api"
image_tag_mutability = "MUTABLE"
image_scan_on_push = true

enable_kms_encryption = true
create_kms_key = true
kms_key_alias = "alias/ecr-pmulani-api"

read_write_access_arns = ["arn:aws:iam::832850273244:user/pmulani-admin", "arn:aws:iam::832850273244:role/pmulani-prod-eks-eu-west-1-iam-role"]   # CI/CD role(s)
pull_access_arns = ["arn:aws:iam::832850273244:user/pmulani-admin", "arn:aws:iam::832850273244:role/pmulani-prod-eks-eu-west-1-iam-role"]   # optional

create_lifecycle_policy = false
expire_untagged_after_days = 7
keep_last_tagged = 10

force_delete = true



#RDS
db_port = "5432"
db_instancename = "api"
db_engine = "postgres"
db_engine_version = "16.6"
db_engine_lifecycle_support = "open-source-rds-extended-support"
db_parameter_group = "postgres16"
db_major_engine_version = "16"
db_instance_class = "db.t4g.large"
db_storage_type = "gp3"
db_instance_allocated_storage = 100
db_instance_max_allocated_storage = 150
db_name = "apidb"
db_username = "postgres"
db_subnet_group_name="pmulani-multiaz"
auto_minor_version_upgrade = false
multi_az = true

iam_database_authentication_enabled = true

#Maintenance
maintenance_window = "Sun:00:00-Sun:03:00"

#Backup
backup_window = "03:00-06:00"
backup_retention_period = 14

#Logs
enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
create_cloudwatch_log_group = true

skip_final_snapshot = false
deletion_protection = true


performance_insights_enabled = true
performance_insights_retention_period = 7
create_monitoring_role = true
monitoring_interval = 0
monitoring_role_name = "pmulani_rds_monitoring_role"
monitoring_role_use_name_prefix = true
monitoring_role_description = "Monitoring Role for RDS used for pmulani Project"

autovacuum = 1
client_encoding = "utf8"

#Security group
security_group_desc = "Security group for rds postgres used in monitoring project."

manage_master_user_password = true

db_internal_record_name = "pg-api-prod-1"