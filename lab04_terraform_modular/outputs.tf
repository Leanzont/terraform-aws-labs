# Values displayed after terraform apply
# Useful to get instance info without opening the AWS console

# Public IP to connect via SSH
output "public_ip" {
  description = "The instance public IP"
  value       = aws_instance.servidor.public_ip 
}

# Instance ID assigned by AWS
output "instance_id" {
  description = "Intance ID"
  value       = aws_instance.servidor.id
}
