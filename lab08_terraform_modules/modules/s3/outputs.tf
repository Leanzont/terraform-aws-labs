output "s3_bucket_arn" {
  value = aws_s3_bucket.main_bucket.arn 
}

output "s3_name" {
  value = aws_s3_bucket.main_bucket.bucket 
}
