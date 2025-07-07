# Example: Complete setup with object storage and web server

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = data.aws_availability_zones.available.names[0]
  default_for_az    = true
}

# Create security group for web server
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Security group for web server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# Create S3 bucket using our storage module
module "storage" {
  source = "../../modules/object-storage"

  bucket_name          = "my-app-storage-${random_pet.bucket_suffix.id}"
  versioning_enabled   = true
  encryption_algorithm = "AES256"

  # lifecycle_rules = [
  #   {
  #     id      = "cleanup_old_versions"
  #     enabled = true
  #     noncurrent_version_expiration = {
  #       noncurrent_days = 30
  #     }
  #   }
  # ]

  tags = {
    Environment = "development"
    Project     = "terraform-best-practices"
  }
}

# Create EC2 instance using our web server module
module "web_server" {
  source = "../../modules/web-server"

  instance_name      = "web-server-${random_pet.instance_suffix.id}"
  instance_type      = "t3.micro"
  security_group_ids = [aws_security_group.web_server.id]
  subnet_id          = data.aws_subnet.default.id
  s3_bucket_name     = module.storage.bucket_id
  s3_bucket_arn      = module.storage.bucket_arn

  tags = {
    Environment = "development"
    Project     = "terraform-best-practices"
  }
}

# Random pet names for unique resource naming
resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "random_pet" "instance_suffix" {
  length = 2
}