# Using terraform-aws-modules/s3-bucket for frontend static hosting
module "s3_frontend" {
  source  = "terraform-aws-modules/s3-bucket/aws"

  bucket = "task-management-app-frontend" # Change to a unique bucket name
  acl    = "public-read"

  # Enable static website hosting
  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  # Block public access (except for website content)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  # Enable versioning for safety
  versioning = {
    enabled = true
  }

  # CORS for frontend API calls to ALB
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://your-cloudfront-id.cloudfront.net"] # Replace with your CloudFront domain
      max_age_seconds = 3000
    }
  ]
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = module.s3_frontend.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.s3_frontend.s3_bucket_arn}/*"
      }
    ]
  })
}