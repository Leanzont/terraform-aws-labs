output "public_ip" {
  description = "Public ip for the intance"
  value      = aws_instance.ec2.public_ip
}

output "bucket_name" {
  description = "Bucket name"
  value       = aws_s3_bucket.main_bucket.bucket
}

output "iam_role" {
  description = "IAM role"
  value       = aws_iam_role.ec2_role.name
}

output "instance_id" {
  description = "Instance ID"
  value       = aws_instance.ec2.id 
}

output "RDS_end_point" {
  description = "RDS end point"
  value       = aws_db_instance.mysql.endpoint 
}
