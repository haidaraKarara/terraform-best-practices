output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

output "bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_region
}