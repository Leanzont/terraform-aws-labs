# security group 
resource "aws_security_group" "sg_ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "my security group ssh and http"
  vpc_id      = var.vpc_id 

  ingress {
    description = "SSH"
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP"
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# key pair 
resource "aws_key_pair" "my_key_ec2" {
  key_name = "my-key-lab08"
  public_key = file("~/terraform/lab08_terraform/modules/ec2/my-key-lab08.pub")
}

# ec2 instance 
resource "aws_instance" "my_instance_ec2" {
  ami                    = var.ami 
  instance_type          = var.instance_type 
  subnet_id              = var.subnet_public_id 
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  key_name               = aws_key_pair.my_key_ec2.key_name 
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-EOF
                  #!/bin/bash
                  yum update -y 
                  amazon-linux-extras enable nginx1
                  yum install -y nginx 
                  yum install -y awscli
                  systemctl start nginx 
                  systemctl enable nginx
                  EOF
  tags = {
    Name = "${var.project_name}-ec2-instance"
  }
}
