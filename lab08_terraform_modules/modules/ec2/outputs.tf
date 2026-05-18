output "aws_instance" {
  value = aws_instance.my_instance_ec2.id
}

output "aws_sg_for_rds" {
  value = aws_security_group.sg_ec2.id
}

output "instance_public_ip" {
  value = aws_instance.my_instance_ec2.public_ip
}
