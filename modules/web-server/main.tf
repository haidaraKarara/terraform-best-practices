# Local values
locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    s3_bucket_name = var.s3_bucket_name
  })
}

# Get latest Amazon Linux 2023 AMI
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

# IAM role for EC2 instance to access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.instance_name}-s3-role"

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

  tags = merge(
    {
      Name      = "${var.instance_name}-s3-role"
      Module    = "web-server"
      ManagedBy = "terraform"
    },
    var.tags
  )
}

# IAM policy for S3 access
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.instance_name}-s3-policy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attach AWS managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_s3_role.name

  tags = merge(
    {
      Name      = "${var.instance_name}-profile"
      Module    = "web-server"
      ManagedBy = "terraform"
    },
    var.tags
  )
}

# Using official terraform-aws-modules/ec2-instance/aws module
# Reference: https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = var.instance_name

  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazon_linux.id
  key_name               = var.key_name
  monitoring             = var.monitoring
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data                   = base64encode(local.user_data)

  root_block_device = {
    type        = var.root_volume_type
    size        = var.root_volume_size
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  tags = merge(
    {
      Name      = var.instance_name
      Module    = "web-server"
      ManagedBy = "terraform"
    },
    var.tags
  )
}