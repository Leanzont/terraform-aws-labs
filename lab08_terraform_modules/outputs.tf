output "public_ip" {
  description = "instance public ip"
  value       = module.ec2.instance_public_ip
}

output "bucket_name" {
  description = "bucket s3 name"
  value       = module.s3.s3_name
}

output "role_name" {
  description = "iam role name instance profile"
  value       = module.iam.instance_profile
}

output "instance_id" {
  description = "ec2 instance id"
  value       = module.ec2.aws_instance
}

output "RDS_end_point" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
}
