# Using official terraform-aws-modules/s3-bucket/aws module
# Reference: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket = var.bucket_name

  # Enable versioning
  versioning = {
    enabled = var.versioning_enabled
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = var.encryption_algorithm
      }
    }
  }

  # Public access block
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access

  # Control object ownership
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # Lifecycle rules
  lifecycle_rule = var.lifecycle_rules != null ? var.lifecycle_rules : []

  # Tags
  tags = merge(
    {
      Name      = var.bucket_name
      Module    = "object-storage"
      ManagedBy = "terraform"
    },
    var.tags
  )
}