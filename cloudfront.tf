# Using terraform-aws-modules/cloudfront for frontend CDN
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"

  # Set S3 bucket as origin
  origin = {
    s3 = {
      domain_name = module.s3_frontend.s3_bucket_bucket_regional_domain_name
      origin_id   = "S3-frontend"
    }
  }

  # Default cache behavior for SPA
  default_cache_behavior = {
    target_origin_id       = "S3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = false
    cookies_forward        = "none"
    default_ttl            = 86400
    min_ttl                = 0
    max_ttl                = 31536000
  }

  # Default root object for React SPA
  default_root_object = "index.html"

  # Geo restrictions (none for global access)
  geo_restriction = {
    restriction_type = "none"
  }

  # Use default CloudFront certificate (Free Tier)
  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  # Logging (optional, disabled to save costs)
  logging_config = {}
}
