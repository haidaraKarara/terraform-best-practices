# Web Server Module

This module creates an EC2 instance using the official `terraform-aws-modules/ec2-instance/aws` module with IAM role configured for S3 access.

## Features

- Uses official terraform-aws-modules/ec2-instance/aws module
- Latest Amazon Linux 2023 AMI
- IAM role and instance profile for S3 access
- Custom user data script for S3 testing
- Encrypted EBS root volume
- Configurable instance type and storage

## Usage

```hcl
module "web_server" {
  source = "./modules/web-server"
  
  instance_name      = "my-web-server"
  instance_type      = "t3.micro"
  key_name           = "my-key-pair"
  security_group_ids = [aws_security_group.web.id]
  subnet_id          = "subnet-12345678"
  s3_bucket_name     = "my-storage-bucket"
  s3_bucket_arn      = "arn:aws:s3:::my-storage-bucket"
  
  tags = {
    Environment = "prod"
    Application = "my-app"
  }
}
```

## What the module creates

### From Official Registry Module:
- **EC2 Instance**: Using `terraform-aws-modules/ec2-instance/aws`
- **Data Source**: Latest Amazon Linux 2023 AMI

### Custom Resources (our additions):
- **IAM Role**: For EC2 to assume with S3 permissions
- **IAM Policy**: Grants S3 read/write access to specified bucket
- **IAM Instance Profile**: Attaches the role to the EC2 instance
- **User Data Script**: Custom script to install AWS CLI and create S3 test tools

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
| instance_name | Name of the EC2 instance | `string` | n/a | yes |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| key_name | Name of the EC2 key pair | `string` | `null` | no |
| monitoring | Enable detailed monitoring | `bool` | `false` | no |
| security_group_ids | List of security group IDs to assign to the instance | `list(string)` | n/a | yes |
| subnet_id | ID of the subnet to launch the instance in | `string` | n/a | yes |
| s3_bucket_name | Name of the S3 bucket the instance will access | `string` | n/a | yes |
| s3_bucket_arn | ARN of the S3 bucket the instance will access | `string` | n/a | yes |
| root_volume_type | Type of root volume | `string` | `"gp3"` | no |
| root_volume_size | Size of root volume in GB | `number` | `20` | no |
| kms_key_id | KMS key ID for EBS encryption | `string` | `null` | no |
| tags | Additional tags for the EC2 instance | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| instance_public_ip | Public IP address of the EC2 instance |
| instance_private_ip | Private IP address of the EC2 instance |
| instance_public_dns | Public DNS name of the EC2 instance |
| instance_private_dns | Private DNS name of the EC2 instance |
| iam_role_name | Name of the IAM role attached to the instance |
| iam_role_arn | ARN of the IAM role attached to the instance |
| iam_instance_profile_name | Name of the IAM instance profile |

## S3 Testing

Once the instance is launched, you can SSH into it and run:

```bash
./s3-test.sh
```

This script will:
1. Create a test file
2. Upload it to S3
3. List S3 objects
4. Download the file back
5. Compare the files to verify integrity