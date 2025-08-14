#VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(module.vpc.vpc_id, null)
}
#Public subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

#Private Subnet
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}