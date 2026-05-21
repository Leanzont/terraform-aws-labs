output "public_ip" {
  description = "Public ip for the instance"
  value       = aws_instance.instance-ec2.public_ip
}

output "bucket_name" {
  description = "bucket name s3"
  value       = aws_s3_bucket.main_bucket.bucket
}

output "iam_role" {
  description = "IAM role"
  value       = aws_iam_role.ec2_role.name
}
