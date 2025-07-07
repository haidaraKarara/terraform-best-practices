# Complete Example: Object Storage + Web Server

This example demonstrates how to use both the `object-storage` and `web-server` modules together to create a complete infrastructure setup.

## What this example creates

1. **S3 Bucket** (via object-storage module):
   - Uses official `terraform-aws-modules/s3-bucket/aws` module
   - Versioning enabled
   - AES256 encryption
   - Lifecycle rules to clean up old versions
   - Public access blocked

2. **EC2 Instance** (via web-server module):
   - Uses official `terraform-aws-modules/ec2-instance/aws` module
   - Amazon Linux 2023 AMI
   - IAM role with S3 access permissions
   - Custom user data script for S3 testing
   - Security group allowing SSH and HTTP

3. **Supporting Resources**:
   - Security group for EC2 instance
   - Random pet names for unique resource naming

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Test S3 connectivity**:
   - SSH into the EC2 instance using the output command
   - Run the S3 test script: `./s3-test.sh`

## Module Dependencies

This example shows how the modules work together:

```
object-storage module → provides bucket_id and bucket_arn
                     ↓
web-server module    → uses bucket info for IAM permissions
```

## Clean up

To destroy all resources:
```bash
terraform destroy
```

## Requirements

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- AWS provider >= 5.0

## Modules Used

- **object-storage**: `../../modules/object-storage`
  - Wraps `terraform-aws-modules/s3-bucket/aws`
- **web-server**: `../../modules/web-server`
  - Wraps `terraform-aws-modules/ec2-instance/aws`