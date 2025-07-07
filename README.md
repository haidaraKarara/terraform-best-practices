# Terraform Best Practices Project

A comprehensive Terraform project demonstrating best practices for AWS infrastructure using official modules from the Terraform Registry.

## 🏗️ Architecture Overview

This project creates a secure, scalable infrastructure with:

- **S3 Bucket**: Object storage with versioning and encryption using `terraform-aws-modules/s3-bucket/aws`
- **EC2 Instance**: Web server with IAM roles using `terraform-aws-modules/ec2-instance/aws`
- **AWS SSM**: Secure access via Session Manager (no SSH keys required)
- **IAM Roles**: Least privilege access for EC2 to S3 operations

## 📁 Project Structure

```
terraform-best-practices/
├── modules/
│   ├── object-storage/          # S3 bucket module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   └── web-server/              # EC2 instance module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       ├── user_data.sh
│       └── README.md
├── examples/
│   └── complete/                # Complete infrastructure example
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       ├── Makefile
│       └── README.md
├── CLAUDE.md                    # Comprehensive best practices guide
├── Makefile                     # Automation commands
├── .gitignore                   # Git ignore patterns
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with necessary permissions

### Deploy the Infrastructure

1. **Clone the repository**:
   ```bash
   git clone https://github.com/haidaraKarara/terraform-best-practices.git
   cd terraform-best-practices
   ```

2. **Navigate to the complete example**:
   ```bash
   cd examples/complete
   ```

3. **Initialize Terraform**:
   ```bash
   make init
   ```

4. **Plan the deployment**:
   ```bash
   make plan
   ```

5. **Apply the infrastructure**:
   ```bash
   make apply
   ```

6. **Connect to your instance**:
   ```bash
   # Use the SSM command from terraform outputs
   aws ssm start-session --target <instance-id>
   ```

### Test S3 Connectivity

Once connected to the EC2 instance via Session Manager:

```bash
# Run the S3 test script
./s3-test.sh
```

## 🔐 Security Features

### AWS Systems Manager Session Manager

This project uses **AWS SSM Session Manager** for secure access instead of traditional SSH:

- ✅ **No SSH keys** to manage or rotate
- ✅ **No open ports** (port 22 is not exposed)
- ✅ **IAM-based access** control
- ✅ **Session logging** via CloudTrail
- ✅ **Browser-based** connection option

### IAM Best Practices

- **Least privilege principle**: EC2 instances have minimal required permissions
- **Managed policies**: Uses AWS managed `AmazonSSMManagedInstanceCore` policy
- **Resource-specific access**: S3 permissions limited to specific bucket

## 📊 What Gets Created

### Storage Module (`object-storage`)
- S3 bucket with unique naming using random_pet
- Versioning enabled for data protection
- Server-side encryption (AES256)
- Public access blocked for security
- Lifecycle rules support (commented examples)

### Compute Module (`web-server`)
- EC2 instance using latest Amazon Linux 2023 AMI
- IAM role with S3 and SSM permissions
- Security group allowing only HTTP traffic (no SSH)
- User data script for automatic configuration
- S3 connectivity testing script

### Infrastructure Components
- VPC and subnet discovery (uses default VPC)
- Security groups with minimal required access
- Random naming for resource uniqueness
- Comprehensive tagging strategy

## 🛠️ Available Commands

### Using Make

```bash
# Initialize Terraform
make init

# Validate configuration
make validate

# Plan changes
make plan

# Apply changes
make apply

# Destroy infrastructure
make destroy

# Format code
make fmt

# Clean temporary files
make clean
```

### Manual Terraform Commands

```bash
# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy
```

## 📋 Outputs

After deployment, you'll get:

- **S3 bucket name** and ARN
- **EC2 instance ID** and IP addresses
- **SSM Session Manager command** for secure connection
- **S3 test command** for verifying connectivity

Example output:
```
ssm_session_command = "aws ssm start-session --target i-0123456789abcdef0"
s3_bucket_name = "my-app-storage-happy-cat"
```

## 🏷️ Module Versions

This project uses pinned versions for reproducibility:

- **S3 Module**: `terraform-aws-modules/s3-bucket/aws` v4.1
- **EC2 Module**: `terraform-aws-modules/ec2-instance/aws` v6.0
- **AWS Provider**: v6.x
- **Random Provider**: v3.x

## 📚 Best Practices Demonstrated

1. **Registry-First Approach**: Uses official modules instead of custom resources
2. **Version Pinning**: All modules and providers use version constraints
3. **Security by Default**: SSM instead of SSH, encryption enabled
4. **Modular Design**: Reusable modules with clear interfaces
5. **Documentation**: Comprehensive README files and inline comments
6. **Automation**: Makefiles for common operations
7. **Clean Code**: Consistent formatting and naming conventions

## 🔧 Customization

### Modify Instance Type

Edit `examples/complete/main.tf`:

```hcl
module "web_server" {
  # ...
  instance_type = "t3.small"  # Change from t3.micro
  # ...
}
```

### Add Lifecycle Rules

Uncomment and modify in `examples/complete/main.tf`:

```hcl
module "storage" {
  # ...
  lifecycle_rules = [
    {
      id      = "cleanup_old_versions"
      enabled = true
      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }
  ]
  # ...
}
```

## 🧹 Cleanup

To destroy all resources:

```bash
make destroy
```

Or manually:

```bash
terraform destroy -auto-approve
```

## 📖 Additional Documentation

- **[CLAUDE.md](./CLAUDE.md)**: Comprehensive Terraform best practices guide
- **[Module Documentation](./modules/)**: Individual module README files
- **[Example Documentation](./examples/complete/README.md)**: Complete example details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the established patterns
4. Test your changes
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure AWS credentials are configured correctly
2. **Resource Already Exists**: Check for naming conflicts, particularly with S3 buckets
3. **SSM Connection Failed**: Verify the instance has the SSM agent running and proper IAM permissions

### Getting Help

- Check the [CLAUDE.md](./CLAUDE.md) file for detailed best practices
- Review module documentation in the `modules/` directory
- Ensure all prerequisites are installed and configured

---

**Generated with ❤️ using Terraform best practices**

🤖 *This project demonstrates real-world Terraform patterns and AWS security best practices.*