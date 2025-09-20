# Using terraform-aws-modules/s3-bucket for frontend static hosting
module "s3_frontend" {
  source  = "terraform-aws-modules/s3-bucket/aws"

  bucket = "saurav-task-management-app-frontend" # Change to a unique bucket name
  #acl    = "public-read"

  # Enable static website hosting
  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  # Block public access (except for website content)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Enable versioning for safety
  versioning = {
    enabled = true
  }

  # CORS for frontend API calls to ALB
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://de0e47pv5ccby.cloudfront.net"] # Replace with your CloudFront domain
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
