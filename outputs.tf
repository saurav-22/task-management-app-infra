# Outputs for VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Outputs for EKS
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

# Outputs for RDS
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.db.db_instance_address
}

# Output ECR repository URIs for Helm values
output "ecr_repository_uris" {
  value = { for k, v in module.ecr : k => v.repository_url }
}

# Output CloudFront domain for GitHub Actions
output "cloudfront_domain" {
  value = module.cloudfront.cloudfront_distribution_domain_name
}

# Outputs for GitHub Actions
output "github_actions_access_key_id" {
  value     = aws_iam_access_key.github_actions_key.id
  sensitive = true
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions_key.secret
  sensitive = true
}

output "github_actions_role_arn" {
  value = module.iam_github_actions.iam_role_arn
}