variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the instance"
  type        = list(string)
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket the instance will access"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the instance will access"
  type        = string
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 30 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 30 and 16384 GB."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for EBS encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the EC2 instance"
  type        = map(string)
  default     = {}
}