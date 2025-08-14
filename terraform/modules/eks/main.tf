data "aws_region" "current" {}
provider "aws" {
  region = var.aws_region
  profile = "kpersonal"
  allowed_account_ids = var.allowed_account_ids
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

locals {
  name      = var.clusterName
  azs                   = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  cluster_version = var.cluster_version
  tags = {
    Project     = var.projectName
    Application = var.applicationName
    Environment = var.env
    ManagedBy   = "terraform"
    Team        = "MyTeam"
    Contact     = "myteam@gmail.com"
  }
  node_security_group_tags = {
    "karpenter.sh/discovery" = "${var.clusterName}"
  }
  control_plane_subnets_len = length(var.control_plane_subnets)
  control_plane_subnet_names = split(";", trim(join("", flatten([for k, v in var.control_plane_subnet_prefix : [for a, b in local.azs : "${v}-${b};"]])), ";"))
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  enable_cluster_creator_admin_permissions = true
  cluster_name    = "${var.clusterName}"
  cluster_version = "${var.cluster_version}"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      addon_version = var.coredns_addon_version
    }
    vpc-cni = {
      addon_version =  var.cni_addon_version
      service_account_role_arn = var.vpc_cni_role_iam_arn
      configuration_values = jsonencode({
        enableNetworkPolicy = var.vpc_cni_enable_np
      })
    }

    kube-proxy = {
      addon_version = var.kubeproxy_addon_version
    }
  }

  vpc_id                   = var.vpc_id # Referenced from VPC module
  subnet_ids               = var.public_subnets
  control_plane_subnet_ids = aws_subnet.control_plane[*].id



  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    # Prod node group
    general-ng = {
      name            = var.self_managed_ng_name
      use_name_prefix = false
      ami_type      = "AL2023_x86_64_STANDARD"
      subnet_ids               = var.private_subnets
      #Following needs to be used for t4g instances which needs to be tested.
      #ami_type = "AL2_ARM_64"
      #ami_id = data.aws_ami.eks_default_arm.image_id

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      enable_bootstrap_user_data = true # to opt in to using the module supplied bootstrap user data template
      bootstrap_extra_args       = "--kubelet-extra-args '--node-labels=cluster=kyvernovis-prod-eks-eu-west-1'"

      instance_type = var.instance_type

      launch_template_name            = var.launch_template_name
      launch_template_use_name_prefix = true
      launch_template_description     = "Self managed node group"

      ebs_optimized     = true
      enable_monitoring = false

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            #iops                  = 3000
            #throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      create_iam_role          = true
      iam_role_name            = var.iam_role_name
      iam_role_use_name_prefix = false
      iam_role_description     = "Self managed ekslabs node group role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        additional                         = aws_iam_policy.readonly-aws-resources.arn
      }

      tags = {
        env = var.env
      }
      tags = local.tags
    }
  }

  node_security_group_tags = local.node_security_group_tags

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow http node to node communication for ingress."
      protocol    = "-1"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
  }
}

module "aws_auth" {
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"
  manage_aws_auth_configmap = false
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::832850273244:user/pmulani-admin"
      username = "pmulani-admin"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = "arn:aws:iam::832850273244:role/Circle-CI-Role"
      username = "circleci"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::832850273244:user/pmulani-admin"
      username = "pmulani-admin"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = [
    "832850273244",
  ]
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_iam_policy" "readonly-aws-resources" {
  name        = "${local.name}-readonly"
  description = "ReadOnly access for AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

# Control Plane Subnet

resource "aws_subnet" "control_plane" {
  count                   = "${length(var.control_plane_subnets)}"
  vpc_id                  = var.vpc_id
  cidr_block              = "${var.control_plane_subnets[count.index]}"
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = false
  tags = {
    Name = try(
      var.control_plane_subnets[count.index],
      format("${var.control_plane_subnet_prefix}-${local.name}-%s", element(var.azs, count.index))
    )
  }
}

resource "aws_route_table" "control_plane_rt" {
  count = local.control_plane_subnets_len
  vpc_id = var.vpc_id
  tags = {
    Name = try(
      var.control_plane_subnets[count.index],
      format("${var.control_plane_subnet_prefix}-${local.name}-%s", element(var.azs, count.index))
    )
  }
}
data "aws_route_table" "existing_cntrl_rt" {
  route_table_id = aws_route_table.control_plane_rt[0].id
}

resource "aws_route_table_association" "public" {
  count = local.control_plane_subnets_len

  subnet_id      = element(aws_subnet.control_plane[*].id, count.index)
  route_table_id = aws_route_table.control_plane_rt[0].id

}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.control_plane_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id

  # W/o or smaller timeouts sometimes api calls error out
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.control_plane_rt[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = var.igw_id
  # W/o or smaller timeouts sometimes api calls error out
  timeouts {
    create = "5m"
  }
}