data "aws_region" "current" {}
provider "aws" {
  region = var.aws_region
  profile = "kpersonal"
  allowed_account_ids = var.allowed_account_ids
}

locals {
  azs = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  private_subnet_names = split(";", trim(join("", flatten([
    for k, v in var.private_subnet_prefix :[for a, b in local.azs : "${v}-${b};"]
  ])), ";"))
  public_subnet_names = split(";", trim(join("", flatten([
    for k, v in var.public_subnet_prefix :[for a, b in local.azs : "${v}-${b};"]
  ])), ";"))
}

module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.clusterName}"
  cidr = var.vpc_cidr

  azs = local.azs

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  create_igw             = true
  map_public_ip_on_launch = true

  private_subnets      = var.private_subnets
  private_subnet_names = local.private_subnet_names

  public_subnets       = var.public_subnets
  public_subnet_names  = local.public_subnet_names

  tags = {
    Project     = var.projectName
    Application = var.applicationName
    Environment = var.env
    ManagedBy   = "terraform"
    Team        = "MyTeam"
    Contact     = "myteam@gmail.com"
  }
}