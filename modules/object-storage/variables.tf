variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be valid S3 bucket name format."
  }
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either AES256 or aws:kms."
  }
}

variable "block_public_access" {
  description = "Block public access to the S3 bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the S3 bucket"
  type = list(object({
    id      = string
    enabled = bool
    prefix  = optional(string)
    tags    = optional(map(string))
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = null
}

variable "tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {}
}