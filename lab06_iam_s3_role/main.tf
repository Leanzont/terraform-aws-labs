# S3 Bucket 
resource "aws_s3_bucket" "main_bucket" {
  bucket = var.bucket_name 

  tags = {
    Name = var.project_name
  }
}

# Block public access to the bucket 
resource "aws_s3_bucket_public_access_block" "main_bucket" {
  bucket = aws_s3_bucket.main_bucket.id 

  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls     = true 
  restrict_public_buckets = true 
}

# IAM Role for EC2 
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust policy - define who can assume this role 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = var.project_name
  }
}

# IAM Policy - define what the role can do in S3, attach policy in role created 
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.project_name}-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main_bucket.arn,
          "${aws_s3_bucket.main_bucket.arn}/*"
        ]
      }
    ]
  })
}


# Instance Profile - Connect the role with EC2 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name 
}

# EC2 Instance 
resource "aws_instance" "instance-ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id 
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name   # <-- instance profile

  vpc_security_group_ids = [aws_security_group.EC2_group.id]
  key_name               = aws_key_pair.my_key_lab06.key_name

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y awscli
                exho 'export TERM=xterm' >> /home/ec2-user/.bashrc
                EOF

  tags = {
    Name = "${var.project_name}-ec2-instance"
  }
}

# Key Pair for the instance 
resource "aws_key_pair" "my_key_lab06" {
  key_name   = "my-key-lab06"
  public_key = file("~/terraform/lab06_terraform/my-key-lab06.pub")  
}

# Security Groups 
resource "aws_security_group" "EC2_group" {
  name        = "${var.project_name}-security-group"   
  description = "ec2 instance lab06 IAM"
# We don't need the VPC ID; use the default VPC. 

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }
  
  egress {
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  

}


 




