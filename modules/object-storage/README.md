# Object Storage Module

This module creates an S3 bucket using the official `terraform-aws-modules/s3-bucket/aws` module.

## Features

- Uses official terraform-aws-modules/s3-bucket/aws module
- Configurable versioning (enabled by default)
- Server-side encryption with AES256 or KMS
- Public access blocked by default
- Lifecycle rules support
- Custom tags support

## Usage

```hcl
module "storage" {
  source = "./modules/object-storage"
  
  bucket_name        = "my-app-storage-bucket"
  versioning_enabled = true
  encryption_algorithm = "AES256"
  
  tags = {
    Environment = "prod"
    Application = "my-app"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| versioning_enabled | Enable versioning for the S3 bucket | `bool` | `true` | no |
| encryption_algorithm | Server-side encryption algorithm | `string` | `"AES256"` | no |
| block_public_access | Block public access to the S3 bucket | `bool` | `true` | no |
| lifecycle_rules | List of lifecycle rules for the S3 bucket | `list(object)` | `null` | no |
| tags | Additional tags for the S3 bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| bucket_domain_name | Domain name of the S3 bucket |
| bucket_regional_domain_name | Regional domain name of the S3 bucket |
| bucket_region | AWS region of the S3 bucket |