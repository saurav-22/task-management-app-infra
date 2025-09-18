# IAM Role for GitHub Actions (CI/CD)
module "iam_github_actions" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role       = true
  role_name         = "task-app-github-actions"
  role_description  = "Role for GitHub Actions to access S3, CloudFront, ECR"

  # Allow all AWS principals (for access key usage)
  trusted_role_arns = ["arn:aws:iam::051101197314:root"] # Replace with your AWS account ID

  custom_role_policy_arns = [
    aws_iam_policy.github_actions.arn
  ]
}

resource "aws_iam_policy" "github_actions" {
  name        = "task-app-github-actions-policy"
  description = "Policy for GitHub Actions CI/CD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${module.s3_frontend.s3_bucket_arn}",
          "${module.s3_frontend.s3_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = module.cloudfront.cloudfront_distribution_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create IAM user for GitHub Actions
resource "aws_iam_user" "github_actions_user" {
  name = "task-app-github-actions-user"
}

resource "aws_iam_access_key" "github_actions_key" {
  user = aws_iam_user.github_actions_user.name
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "github_actions_user_policy" {
  user       = aws_iam_user.github_actions_user.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# IAM Role for EKS Cluster
module "eks_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = ["eks.amazonaws.com"]
  create_role          = true
  role_name           = "task-app-eks-cluster"
  role_description    = "Role for EKS cluster"

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

# IAM Role for ALB Ingress Controller
module "alb_ingress_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = ["eks.amazonaws.com"]
  create_role          = true
  role_name           = "task-app-alb-ingress"
  role_description    = "Role for ALB Ingress Controller"

  custom_role_policy_arns = [
    aws_iam_policy.alb_ingress.arn
  ]
}

resource "aws_iam_policy" "alb_ingress" {
  name        = "task-app-alb-ingress-policy"
  description = "Policy for ALB Ingress Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "elasticloadbalancing:*",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "*"
      }
    ]
  })
}
