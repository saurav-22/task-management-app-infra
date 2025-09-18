# Using terraform-aws-modules/ecr for backend microservices
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"

  # Create a repository for each microservice
  for_each = toset(["user-service", "board-service", "task-service", "comment-service"])

  repository_name = "task-management-app/${each.key}"
  repository_type = "private"

  # Enable image scanning on push for security
  repository_image_scan_on_push = false

  # Lifecycle policy to keep only the last 10 images
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Allow read/write access for GitHub Actions and EKS
  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            module.iam_github_actions.iam_role_arn,
            module.eks_iam_role.iam_role_arn
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}
