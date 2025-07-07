output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = module.ec2_instance.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_instance.public_dns
}

output "instance_private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = module.ec2_instance.private_dns
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the instance"
  value       = aws_iam_role.ec2_s3_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance"
  value       = aws_iam_role.ec2_s3_role.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}