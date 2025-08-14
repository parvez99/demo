################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}


################################################################################
# Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id"    {
  value = module.eks.node_security_group_id
}
################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}
################################################################################
# EKS Identity Provider
################################################################################

output "cluster_identity_providers" {
  description = "Map of attribute maps for all EKS identity providers enabled"
  value       = module.eks.cluster_identity_providers
}

################################################################################
# Self Managed Node Group
################################################################################

output "self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value       = module.eks.self_managed_node_groups
}

output "self_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by self-managed node groups"
  value       = module.eks.self_managed_node_groups_autoscaling_group_names
}

################################################################################
# Additional
################################################################################

#Control Plane subnets
output "control_plane_subnets" {
  description = "List of IDs of control plane subnets"
  value       = aws_subnet.control_plane[*].id
}


output "control_plane_subnet_arns" {
  description = "List of ARNs of control plane subnets"
  value       = aws_subnet.control_plane[*].arn
}