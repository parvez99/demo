variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = ["832850273244"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "clusterName" {
  type        = string
  description = "Cluster Name"
}

variable "projectName" {
  type        = string
  description = "Project Name"
}

variable "applicationName" {
  type        = string
  description = "Application Name"
}

variable "env" {
  type        = string
  description = "Environment"
}
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
