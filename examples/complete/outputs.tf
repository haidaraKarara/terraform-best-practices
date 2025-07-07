output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.storage.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.storage.bucket_arn
}

output "ec2_instance_id" {
  description = "ID of the created EC2 instance"
  value       = module.web_server.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.web_server.instance_public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.web_server.instance_private_ip
}

output "ssm_session_command" {
  description = "AWS SSM Session Manager command to connect to the instance"
  value       = "aws ssm start-session --target ${module.web_server.instance_id}"
}

output "s3_test_command" {
  description = "Command to test S3 connectivity from EC2"
  value       = "Run './s3-test.sh' after connecting via Session Manager"
}