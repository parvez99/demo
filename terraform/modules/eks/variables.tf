variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = ["832850273244"]
}

# This VPC ID is being read from the output of VPC module from ./modules/network
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# EKS #

variable "projectName" {
  type        = string
  description = "Project Name"
}

variable "applicationName" {
  type        = string
  description = "Application Name"
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

variable "self_managed_ng_name" {
  type        = string
  description = "Self managed stage node group"
}


# Addons #
variable "coredns_addon_version" {
  type        = string
  description = "Coredns Version"
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
  description = "Default instance type for staging env"
}

variable "min_size" {
  type        = number
  description = "Min ec2 instances"
}
variable "max_size" {
  type        = number
  description = "Max ec2 instances"
}
variable "desired_size" {
  type        = number
  description = "Desired number of ec2 instances"
}

#LT
variable "launch_template_name" {
  type        = string
  description = "Launch template name for stage env"
}

#Volume
variable "volume_size" {
  type        = number
  description = "Volume size of staging ec2 nodes"
}
variable "volume_type" {
  type        = string
  description = "EBS volume type of staging ec2 nodes"
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

variable "node_security_group_tags" {
  description = "Additional tags for the node security groups"
  type        = map(string)
  default     = {}
}

variable "igw_id" {
  description = "The ID of the IG"
  type        = string
}

# Team #
variable "team" {
  description = "My Team"
  type        = string
  default     = "MyTeam"
}

