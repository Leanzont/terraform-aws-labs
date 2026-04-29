output "public_ip" {
  description = "The instance public IP"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "Instane ID"
  value       = aws_instance.web.id  
}

output "RDS_end_point" {
  description = "RDS end point"
  value       = aws_db_instance.mysql.endpoint
}
