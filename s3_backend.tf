# Create S3 Bucket
resource "aws_s3_bucket" "tf_state" {
  bucket = "saurav-tf-backend-state"
  tags = {
    Name = "Terraform State Bucket"
  }
}
# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
# Enable S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# Create DynamoDB Table for State Locking
resource "aws_dynamodb_table" "tf_state_lock" {
  name         = "saurav-tf-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}