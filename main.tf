terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Configure the S3 backend for Terraform state
  backend "s3" {
    bucket         = "saurav-tf-backend-state"
    key            = "tf-state/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "saurav-tf-state-lock"
    encrypt        = true

  }
  required_version = ">= 1.12.0"
}
provider "aws" {
  region = "ap-south-1"
}