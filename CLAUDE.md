# Terraform Best Practices Guide

## Table of Contents
1. [Official Documentation & Resources](#official-documentation--resources)
2. [Getting Started](#getting-started)
3. [Project Structure](#project-structure)
4. [Best Practices](#best-practices)
5. [Module Development](#module-development)
6. [Real-World Module Development: Lessons Learned](#real-world-module-development-lessons-learned)
7. [State Management](#state-management)
8. [Security Best Practices](#security-best-practices)
9. [Testing & Validation](#testing--validation)
10. [CI/CD Integration](#cicd-integration)
11. [Troubleshooting & Debugging](#troubleshooting--debugging)

## Official Documentation & Resources

### Core Resources
- **Official Documentation**: https://www.terraform.io/docs
- **Terraform Registry (Modules & Providers)**: https://registry.terraform.io/
- **Download Terraform**: https://www.terraform.io/downloads
- **Terraform Cloud**: https://app.terraform.io/
- **HashiCorp Learn**: https://learn.hashicorp.com/terraform

### Community Resources
- **GitHub Examples**: https://github.com/hashicorp/terraform-guides
- **Terraform Community Forums**: https://discuss.hashicorp.com/c/terraform-core
- **Terraform AWS Modules**: https://github.com/terraform-aws-modules

## Getting Started

### Installation
```bash
# macOS (using Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (using Chocolatey)
choco install terraform
```

### Version Management
Use **tfenv** for managing multiple Terraform versions:
```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
```

### First Step: Check the Registry!
**Before writing any Terraform code, ALWAYS check the Terraform Registry first:**
1. Visit https://registry.terraform.io/
2. Search for the resource type you need (e.g., "aws vpc", "azure kubernetes", "google compute")
3. Look for modules with high download counts and recent updates
4. Use official modules instead of writing resources from scratch

Example workflow:
```bash
# Need to create a VPC? Don't write it from scratch!
# 1. Go to registry.terraform.io
# 2. Search "aws vpc"
# 3. Find terraform-aws-modules/vpc/aws
# 4. Use it in your code:

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  # Configuration here
}
```

## Project Structure

### Recommended Directory Structure
```
terraform-project/
├── bootstrap/              # Initial setup and prerequisites
│   ├── backend/           # S3 bucket and DynamoDB for state
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── init-backend.sh    # Script to initialize backend
│   └── README.md          # Bootstrap instructions
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   │   └── ...
│   └── storage/
│       └── ...
├── global/                 # Resources shared across all environments
│   ├── iam/
│   ├── dns/
│   └── monitoring/
├── scripts/               # Utility scripts for operations
│   ├── deploy.sh         # Deployment automation
│   ├── destroy.sh        # Cleanup script
│   ├── rotate-keys.sh    # Security operations
│   └── backup-state.sh   # State backup utility
├── .github/               # GitHub Actions workflows
│   └── workflows/
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
├── docs/                  # Additional documentation
│   ├── architecture.md
│   └── runbook.md
├── tests/                 # Terratest or other tests
│   └── vpc_test.go
├── .gitignore
├── .terraform-version
├── .pre-commit-config.yaml
├── README.md
└── Makefile
```

### File Naming Conventions
- `main.tf` - Primary configuration
- `variables.tf` - Variable declarations
- `outputs.tf` - Output values
- `versions.tf` - Provider version constraints
- `backend.tf` - Backend configuration
- `data.tf` - Data sources
- `locals.tf` - Local values

## Best Practices

### 1. Code Organization
- **ALWAYS check Terraform Registry first** before creating custom resources
- **One resource per file** for large configurations
- **Group related resources** in the same file for small configurations
- **Use modules** for reusable components
- **Separate environments** using directories or workspaces

### 2. Naming Conventions
```hcl
# Resources: use underscore
resource "aws_instance" "web_server" {
  # ...
}

# Variables: use underscore
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Outputs: use underscore
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

# Tags: use consistent naming
tags = {
  Name        = "web-server-${var.environment}"
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "terraform"
}
```

### 3. Variables Best Practices
```hcl
# Always include description and type
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# Use object types for complex variables
variable "instance_config" {
  description = "Configuration for EC2 instances"
  type = object({
    instance_type = string
    volume_size   = number
    volume_type   = string
  })
  default = {
    instance_type = "t3.micro"
    volume_size   = 20
    volume_type   = "gp3"
  }
}
```

### 4. Resource Management

**IMPORTANT: Always check the Terraform Registry (https://registry.terraform.io/) for official modules before creating resources from scratch!**

```hcl
# ❌ AVOID: Creating resources from scratch
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  count = 3
  vpc_id = aws_vpc.main.id
  # ... many more resources to configure
}

# ✅ PREFER: Use official modules
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
}
```

**Benefits of using official modules:**
- Implements best practices automatically
- Handles edge cases and complex configurations
- Regular security updates
- Community-tested and production-ready
- Saves development time

```hcl
# Use data sources for existing resources
# Ubuntu AMI (LTS version)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Amazon Linux 2023 AMI (latest stable)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Amazon Linux 2 AMI (if you need the older version)
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Use lifecycle rules when needed
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id  # Using the Amazon Linux AMI
  instance_type = "t3.micro"
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["LastModified"]]
  }
}

# Use count and for_each appropriately
resource "aws_instance" "web" {
  for_each = var.instance_names
  
  instance_type = var.instance_type
  tags = {
    Name = each.key
  }
}
```

### 5. State Management Best Practices
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "env/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 6. Provider Configuration
```hcl
# versions.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# main.tf
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

## Module Development

### IMPORTANT: Prioritize Official Modules

**Before creating custom modules, ALWAYS check the Terraform Registry first!**

The Terraform Registry (https://registry.terraform.io/) contains thousands of pre-built, tested, and maintained modules. Using official modules is a best practice because:

1. **Battle-tested**: Used by thousands of organizations
2. **Well-maintained**: Regular updates and bug fixes
3. **Best practices built-in**: Security, naming conventions, and patterns
4. **Documentation**: Comprehensive examples and usage guides
5. **Community support**: Issues and improvements from the community

### Finding Official Modules

#### Popular Official Module Publishers:
- **terraform-aws-modules/** - AWS modules maintained by Anton Babenko
- **hashicorp/** - Official HashiCorp modules
- **terraform-google-modules/** - Google Cloud modules
- **Azure/terraform-azurerm-** - Azure official modules

#### Example: Using Official Modules Instead of Custom

❌ **AVOID creating custom modules for common resources:**
```hcl
# Don't reinvent the wheel!
module "vpc" {
  source = "./modules/vpc"  # Custom module
  # ...
}
```

✅ **USE official modules from the Registry:**
```hcl
# Use the official AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Use the official RDS module
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"
  
  identifier = "demodb"
  
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "demodb"
  username = "user"
  port     = "5432"
  
  vpc_security_group_ids = [module.security_group.security_group_id]
  
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

# Use the official EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"
  
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      
      instance_types = ["t3.small"]
    }
  }
}

# Use the official S3 module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  
  bucket = "my-s3-bucket-${random_pet.this.id}"
  acl    = "private"
  
  versioning = {
    enabled = true
  }
  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

### When to Use Official Modules vs Custom Modules

#### Use Official Modules When:
- Creating standard infrastructure (VPC, EKS, RDS, S3, etc.)
- The module exists in the Registry with good ratings
- You need battle-tested, production-ready code
- You want to follow AWS/Azure/GCP best practices
- You need comprehensive features out of the box

#### Create Custom Modules When:
- You have company-specific requirements
- Combining multiple resources in a unique way
- Implementing company policies or standards
- The official module doesn't meet your needs
- Creating application-specific infrastructure patterns

### How to Evaluate Official Modules

Before using a module from the Registry, check:

1. **Downloads**: Higher download count indicates popularity
2. **Last Updated**: Should be recently maintained
3. **GitHub Stars**: Check the source repository
4. **Issues**: Review open issues for potential problems
5. **Examples**: Look for comprehensive examples
6. **Documentation**: Must have clear documentation

### Module Structure
```
modules/vpc/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── examples/
    ├── simple/
    │   └── main.tf
    └── complete/
        └── main.tf
```

### Module Best Practices
```hcl
# modules/vpc/variables.tf
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

# modules/vpc/main.tf
locals {
  common_tags = {
    Module = "vpc"
    Name   = var.vpc_name
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  
  tags = merge(
    local.common_tags,
    {
      Name = var.vpc_name
    }
  )
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}
```

### Using Modules
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = "production-vpc"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Using modules from Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
}
```

## Real-World Module Development: Lessons Learned

This section documents lessons learned from actual module development, including common pitfalls and their solutions.

### Case Study: Object Storage + Web Server Modules

During the development of `object-storage` and `web-server` modules, we encountered several real-world issues that reinforce the importance of following registry-first best practices.

#### Issue 1: Lifecycle Configuration Argument Error

**Problem**: Used incorrect argument name `lifecycle_configuration` instead of `lifecycle_rule`

```hcl
# ❌ WRONG - causes "Unsupported argument" error
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  
  lifecycle_configuration = {
    rule = var.lifecycle_rules
  }
}
```

**Solution**: Always check the official module documentation for correct argument names

```hcl
# ✅ CORRECT - uses the proper argument name
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  
  lifecycle_rule = var.lifecycle_rules
}
```

**Lesson**: Official modules may use different argument names than the underlying AWS provider resources.

#### Issue 2: Variable Structure Mismatch

**Problem**: Variable structure didn't match what the module expected

```hcl
# ❌ WRONG - module expects different structure
variable "lifecycle_rules" {
  type = list(object({
    id     = string
    status = string  # Module expects 'enabled' boolean
  }))
}
```

**Solution**: Match the module's expected input format

```hcl
# ✅ CORRECT - matches module expectations
variable "lifecycle_rules" {
  type = list(object({
    id      = string
    enabled = bool  # Correct: boolean instead of string
    prefix  = optional(string)
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
}
```

#### Issue 3: Module and Provider Version Compatibility

**Problem**: Module versions incompatible with AWS provider versions caused deployment failures

```hcl
# ❌ PROBLEMATIC - version incompatibility
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"  # Too loose constraint
    }
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"  # Incompatible with AWS provider 6.x
}
```

**Error encountered**:
```
Error: Unsupported argument
  on .terraform/modules/web_server.ec2_instance/main.tf line 26
  26:   cpu_core_count = var.cpu_core_count
An argument named "cpu_core_count" is not expected here.
```

**Root Cause**: 
- EC2 module v5.x used arguments removed in AWS provider v6.x
- Module version was designed for older provider versions
- Version constraints were too loose

**Solution**: Use compatible module and provider versions with proper constraints

```hcl
# ✅ CORRECT - compatible versions with proper constraints
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"  # Specific major version
    }
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"  # Compatible with AWS provider 6.x
}
```

**Best Practices for Version Management**:

1. **Check Module Compatibility Matrix**: Always verify which provider versions the module supports
2. **Use Specific Major Versions**: Avoid `>= 5.0`, prefer `~> 6.0`
3. **Pin Module Versions**: Use `~> 6.0` instead of `>= 6.0`
4. **Test Version Combinations**: Validate provider + module combinations before production

```hcl
# ✅ RECOMMENDED version constraints
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"  # Allow 6.x.x updates, not 7.x.x
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"  # Specific major version
    }
  }
}
```

**Version Compatibility Reference** (as of January 2025):

| Module | Version | Compatible AWS Provider |
|--------|---------|------------------------|
| terraform-aws-modules/s3-bucket/aws | ~> 4.0 | ~> 6.0 |
| terraform-aws-modules/ec2-instance/aws | ~> 6.0 | ~> 6.0 |
| terraform-aws-modules/vpc/aws | ~> 5.0 | ~> 5.0, ~> 6.0 |
| terraform-aws-modules/rds/aws | ~> 6.0 | ~> 6.0 |

**Lesson**: Module and provider version compatibility is critical for successful deployments. Always check compatibility matrices and use specific version constraints.

#### Issue 4: Terraform Init Upgrade in Makefiles

**Problem**: Using `terraform init -upgrade` in Makefiles caused unpredictable builds

```makefile
# ❌ PROBLEMATIC - auto-upgrades providers
init:
	terraform init -upgrade
```

**Issues with this approach**:
- Version drift between team members
- Unpredictable CI/CD builds
- Potential breaking changes
- Lock file conflicts

**Solution**: Separate `init` and `upgrade` targets

```makefile
# ✅ BETTER - predictable initialization
init:
	terraform init

# Explicit upgrade with confirmation
upgrade:
	@echo "⚠️  Upgrading provider versions - this may break existing configurations!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform init -upgrade
```

### Module Development Workflow Improvements

Based on our experience, here's the improved workflow:

#### 1. Research Phase
```bash
# Always start by searching the registry
# Visit: https://registry.terraform.io/
# Search for: "s3 bucket", "ec2 instance", etc.
# Check: terraform-aws-modules/* for official modules
```

#### 2. Validation Phase
```bash
# Use proper formatting and validation
make fmt      # Format files first
make validate # Then validate (depends on fmt)
make plan     # Create execution plan
```

#### 3. Module Structure Best Practices

```
modules/
├── object-storage/           # Use descriptive, purpose-based names
│   ├── main.tf              # Wrapper around official module
│   ├── variables.tf         # Match official module's input format
│   ├── outputs.tf           # Expose useful outputs
│   ├── versions.tf          # Pin provider versions
│   └── README.md            # Document what YOU add vs. official module
└── web-server/              # Not just "ec2" - describe the purpose
    ├── main.tf              # Official module + custom IAM resources
    ├── variables.tf         # Include both module and custom inputs
    ├── outputs.tf           # Expose both module and custom outputs
    ├── versions.tf          # Consistent provider versions
    ├── user_data.sh         # Custom application logic
    └── README.md            # Clear documentation
```

#### 4. Documentation Strategy

Your module README should clearly distinguish:

```markdown
## What the module creates

### From Official Registry Module:
- **S3 Bucket**: Using `terraform-aws-modules/s3-bucket/aws`
- **EC2 Instance**: Using `terraform-aws-modules/ec2-instance/aws`

### Custom Resources (our additions):
- **IAM Role**: For EC2 to access S3
- **IAM Policy**: S3 read/write permissions
- **User Data Script**: Application-specific setup
```

### Common Anti-Patterns to Avoid

#### 1. Don't Reinvent Registry Modules
```hcl
# ❌ DON'T: Create custom S3 resource when official module exists
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  # ... 50+ lines of configuration
}

# ✅ DO: Use official module and extend as needed
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # ... clean, simple configuration
}
```

#### 2. Don't Auto-Upgrade in Automation
```makefile
# ❌ DON'T: Auto-upgrade in regular workflow
validate: init-upgrade

# ✅ DO: Keep upgrades explicit and intentional
validate: fmt
upgrade: # Separate, explicit target
```

#### 3. Don't Skip Module Documentation Research
- Always check the module's GitHub repository for examples
- Read the CHANGELOG for breaking changes
- Look at input/output variable documentation
- Test with simple examples first

### Key Takeaways

1. **Registry-First**: Always check terraform-aws-modules/* before building custom resources
2. **Test Incrementally**: Start with basic configurations, add complexity gradually
3. **Version Pinning**: Pin module versions for reproducible builds
4. **Clear Documentation**: Document what YOU add vs. what comes from official modules
5. **Predictable Automation**: Separate initialization from upgrades in tooling

## State Management

### Bootstrap: Setting Up Remote State

**IMPORTANT: Before using remote state, you must bootstrap the backend infrastructure!**

The bootstrap process creates the S3 bucket and DynamoDB table needed for state management. This is a one-time setup that should be done before creating any other infrastructure.

#### Bootstrap Directory Structure
```
bootstrap/
├── backend/
│   ├── main.tf         # S3 bucket and DynamoDB table
│   ├── variables.tf    # Region, bucket name, etc.
│   ├── outputs.tf      # Bucket name and table name
│   └── versions.tf     # Provider versions
├── init-backend.sh     # Automation script
└── README.md          # Setup instructions
```

#### Bootstrap Terraform Configuration
```hcl
# bootstrap/backend/main.tf
provider "aws" {
  region = var.aws_region
}

# S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${var.environment}"
  
  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name        = "Terraform State"
    Environment = var.environment
    Purpose     = "terraform-state"
  }
}

# Enable versioning for state history
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.project_name}-terraform-state-lock-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform State Lock"
    Environment = var.environment
    Purpose     = "terraform-state-lock"
  }
}

# bootstrap/backend/outputs.tf
output "state_bucket_name" {
  description = "Name of the S3 bucket for state storage"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "state_bucket_region" {
  description = "Region of the S3 bucket"
  value       = var.aws_region
}
```

#### Bootstrap Script
```bash
#!/bin/bash
# bootstrap/init-backend.sh

set -euo pipefail

echo "Initializing Terraform Backend Infrastructure"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo -e "${RED}❌ AWS CLI is not configured. Please run 'aws configure'${NC}"
    exit 1
fi

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

echo -e "${GREEN}✓ AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${GREEN}✓ AWS Region: ${AWS_REGION}${NC}"

# Navigate to bootstrap directory
cd "$(dirname "$0")/backend"

# Initialize Terraform
echo -e "${YELLOW}→ Initializing Terraform...${NC}"
terraform init

# Plan the changes
echo -e "${YELLOW}→ Planning backend infrastructure...${NC}"
terraform plan -out=backend.tfplan

# Ask for confirmation
echo -e "${YELLOW}Do you want to create the backend infrastructure? (yes/no)${NC}"
read -r response

if [[ "$response" == "yes" ]]; then
    echo -e "${YELLOW}→ Creating backend infrastructure...${NC}"
    terraform apply backend.tfplan
    
    # Output the backend configuration
    echo -e "${GREEN}✅ Backend infrastructure created successfully!${NC}"
    echo -e "${GREEN}Add this to your backend.tf:${NC}"
    echo "
terraform {
  backend \"s3\" {
    bucket         = \"$(terraform output -raw state_bucket_name)\"
    key            = \"path/to/your/terraform.tfstate\"
    region         = \"$(terraform output -raw state_bucket_region)\"
    dynamodb_table = \"$(terraform output -raw state_lock_table_name)\"
    encrypt        = true
  }
}"
else
    echo -e "${RED}❌ Backend creation cancelled${NC}"
    exit 1
fi
```

### Remote State Configuration
```hcl
# Create S3 bucket for state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### State Commands
```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.example

# Move resource in state
terraform state mv aws_instance.example aws_instance.web

# Remove resource from state
terraform state rm aws_instance.example

# Pull remote state
terraform state pull

# Push state to remote
terraform state push
```

## Security Best Practices

### 1. Sensitive Data Management
```hcl
# Mark variables as sensitive
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

# Use environment variables
# export TF_VAR_db_password="secret"
```

### 2. IAM Best Practices
```hcl
# Use least privilege principle
resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}
```

### 3. AWS Systems Manager (SSM) for Secure Access

**IMPORTANT: Use AWS Systems Manager Session Manager instead of SSH for secure EC2 access!**

#### Benefits of SSM Session Manager:
- **No SSH Keys**: No need to manage SSH key pairs
- **No Open Ports**: No need to open port 22 in security groups
- **Centralized Access**: All access managed through IAM policies
- **Audit Trail**: All sessions logged in CloudTrail
- **Browser-based**: Can connect through AWS Console or CLI

#### Required IAM Configuration:
```hcl
# IAM role for EC2 instance
resource "aws_iam_role" "ssm_role" {
  name_prefix = "${var.project_name}-ssm-"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile to attach role to EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name_prefix = "${var.project_name}-ssm-"
  role        = aws_iam_role.ssm_role.name
}
```

#### User Data Script for SSM Agent:
```bash
#!/bin/bash
# Install and configure AWS Systems Manager Agent
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Verify SSM Agent status
if systemctl is-active --quiet amazon-ssm-agent; then
    echo "✅ SSM Agent is running and ready for Session Manager"
else
    echo "❌ SSM Agent failed to start properly"
fi
```

#### Connection Commands:
```bash
# Connect via AWS CLI
aws ssm start-session --target i-1234567890abcdef0

# Connect via AWS CLI with specific region
aws ssm start-session --target i-1234567890abcdef0 --region us-east-1

# List available instances for SSM
aws ssm describe-instance-information --query "InstanceInformationList[*].[InstanceId,PlatformType,PlatformName]" --output table
```

#### Security Group Configuration:
```hcl
# Secure security group - NO SSH port 22!
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Security group for web server"
  vpc_id      = var.vpc_id

  # Only application ports (no SSH)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Troubleshooting SSM Connection:
```bash
# Check if instance is registered with SSM
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=i-1234567890abcdef0"

# Check SSM agent status on instance (if you have access)
sudo systemctl status amazon-ssm-agent

# View SSM agent logs
sudo tail -f /var/log/amazon/ssm/amazon-ssm-agent.log
```

### 4. .gitignore Configuration
```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore Mac .DS_Store files
.DS_Store
```

## Testing & Validation

### 1. Terraform Validation
```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan with detailed output
terraform plan -out=tfplan

# Show plan in JSON format
terraform show -json tfplan > tfplan.json
```

### 2. Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
```

### 3. Testing with Terratest
```go
// test/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/vpc",
        Vars: map[string]interface{}{
            "vpc_name": "test-vpc",
            "vpc_cidr": "10.0.0.0/16",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Terraform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  TF_VERSION: 1.5.0

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        
      - name: Terraform Validate
        run: terraform validate
        
      - name: Terraform Plan
        if: github.event_name == 'pull_request'
        run: terraform plan -no-color
        
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
```

### GitLab CI Example
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/environments/prod
  TF_IN_AUTOMATION: "true"

before_script:
  - cd ${TF_ROOT}
  - terraform init

validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform validate

plan:
  stage: plan
  script:
    - terraform plan -out=plan.tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/plan.tfplan

apply:
  stage: apply
  script:
    - terraform apply plan.tfplan
  dependencies:
    - plan
  only:
    - main
```

## Troubleshooting & Debugging

### Debug Logging
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR

# Debug specific provider
export TF_LOG_PROVIDER=DEBUG
```

### Common Issues & Solutions

#### 1. State Lock Issues
```bash
# Force unlock state
terraform force-unlock <LOCK_ID>

# Manually remove lock from DynamoDB
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID": {"S": "<LOCK_ID>"}}'
```

#### 2. Resource Already Exists
```bash
# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Or use import block (Terraform 1.5+)
import {
  to = aws_instance.example
  id = "i-1234567890abcdef0"
}
```

#### 3. Dependency Issues
```hcl
# Explicit dependencies
resource "aws_instance" "example" {
  # ...
  
  depends_on = [
    aws_iam_role_policy.example,
    aws_security_group.example
  ]
}
```

### Performance Optimization
```hcl
# Use -parallelism flag
terraform apply -parallelism=20

# Use -target for specific resources
terraform apply -target=aws_instance.example

# Use refresh=false for faster plans
terraform plan -refresh=false
```

## Advanced Patterns

### 1. Dynamic Blocks
```hcl
resource "aws_security_group" "example" {
  name = "example"
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### 2. Conditional Resources
```hcl
resource "aws_instance" "example" {
  count = var.create_instance ? 1 : 0
  
  instance_type = var.instance_type
  # ...
}
```

### 3. Workspace Management
```bash
# Create workspace
terraform workspace new prod

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select prod

# Use in configuration
resource "aws_instance" "example" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  
  tags = {
    Environment = terraform.workspace
  }
}
```

## Makefile Example

### Improved Makefile with Proper Dependencies

```makefile
.PHONY: help init upgrade validate plan apply destroy fmt docs clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  upgrade  - Upgrade provider versions (use with caution)"
	@echo "  validate - Validate Terraform files"
	@echo "  plan     - Create execution plan"
	@echo "  apply    - Apply changes"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  fmt      - Format Terraform files"
	@echo "  docs     - Generate documentation"
	@echo "  clean    - Clean temporary files"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init

# Upgrade provider versions (use with caution)
upgrade:
	@echo "⚠️  Upgrading provider versions - this may break existing configurations!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform init -upgrade

# Format Terraform files
fmt: init
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Validate Terraform configuration
validate: fmt
	@echo "Validating Terraform configuration..."
	terraform validate

# Create execution plan
plan: validate
	@echo "Creating execution plan..."
	terraform plan -out=tfplan

# Apply changes
apply: plan
	@echo "Applying changes..."
	terraform apply tfplan

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	terraform destroy -auto-approve

# Generate documentation (requires terraform-docs)
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README.md --output-mode inject .; \
	else \
		echo "terraform-docs not found. Install it with: brew install terraform-docs"; \
	fi

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl
	rm -rf .terraform/
```

### Key Improvements in This Makefile

1. **Separated `init` and `upgrade`**: Prevents accidental provider upgrades
2. **Proper dependency chain**: `init` → `fmt` → `validate` → `plan` → `apply`
3. **Safety confirmations**: Destructive operations require confirmation
4. **Clean target**: Removes temporary files for fresh starts
5. **Tool checks**: Verifies tools are installed before using them

### Alternative: Project-Specific Makefile for Examples

For example directories, use a more specific Makefile:

```makefile
.PHONY: help init upgrade validate plan apply destroy fmt clean test

help:
	@echo "Available targets:"
	@echo "  init     - Initialize Terraform"
	@echo "  upgrade  - Upgrade provider versions (use with caution)"
	@echo "  validate - Validate Terraform files"
	@echo "  plan     - Create execution plan"
	@echo "  apply    - Apply changes"
	@echo "  destroy  - Destroy infrastructure"
	@echo "  fmt      - Format Terraform files"
	@echo "  clean    - Clean temporary files"
	@echo "  test     - Test infrastructure connectivity"

init:
	@echo "Initializing Terraform..."
	terraform init

upgrade:
	@echo "⚠️  Upgrading provider versions - this may break existing configurations!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform init -upgrade

fmt: init
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

validate: fmt
	@echo "Validating Terraform configuration..."
	terraform validate

plan: validate
	@echo "Creating execution plan..."
	terraform plan -out=tfplan

apply: plan
	@echo "Applying changes..."
	terraform apply tfplan
	@echo ""
	@echo "🎉 Infrastructure deployed successfully!"
	@echo "📋 Next steps:"
	@echo "   1. SSH into the instance: $$(terraform output -raw ssh_command)"
	@echo "   2. Test S3 connectivity: ./s3-test.sh"

destroy:
	@echo "⚠️  This will destroy all infrastructure!"
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	terraform destroy

fmt: init
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

clean:
	@echo "Cleaning temporary files..."
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl
	rm -rf .terraform/

test:
	@echo "Testing infrastructure..."
	@INSTANCE_IP=$$(terraform output -raw ec2_public_ip 2>/dev/null || echo ""); \
	if [ -z "$$INSTANCE_IP" ]; then \
		echo "❌ No EC2 instance found. Run 'make apply' first."; \
		exit 1; \
	fi; \
	echo "📍 Instance IP: $$INSTANCE_IP"; \
	echo "🔗 SSH command: $$(terraform output -raw ssh_command)"; \
	echo "🧪 Run './s3-test.sh' after SSH-ing into the instance"
```

## Conclusion

This guide provides a comprehensive foundation for Terraform best practices. Remember to:

1. Always use version control
2. Test your changes in non-production environments first
3. Keep your modules small and focused
4. Document your code thoroughly
5. Stay updated with Terraform releases and provider changes
6. Engage with the Terraform community for continued learning

For the latest updates and more detailed information, always refer to the [official Terraform documentation](https://www.terraform.io/docs).

---

**Last Updated**: January 2025  
**Terraform Version**: 1.5+