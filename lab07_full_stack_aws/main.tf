# Principal VPC 
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" 
  enable_dns_hostnames = true 
  enable_dns_support    = true

  tags = {
    Name = var.project_name
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.project_name
  }
}

# Public Subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true # <--- assigns public ip 

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Private Subnet 
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# Rote Table 
resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate the route table with the public subnet 
resource "aws_route_table_association" "public-subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet.id 
}

# Security Group EC2 
resource "aws_security_group" "ec2_instance" {
  name        = "${var.project_name}-sg-ec2"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  # for ingres only my ip on ssh
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

  # for ingress any ip http
  ingress {
    description = "HTTP"
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-ec2"
  }
}


# Key Pair for EC2 
resource "aws_key_pair" "my_key" {
  key_name = "my-key-lab07"
  public_key = file("~/terraform/lab07_terraform/my-key-lab07.pub")
} 

# put EC2 in public subnet 
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id  # <-- this use the id the public_subnet
  vpc_security_group_ids = [aws_security_group.ec2_instance.id] 
  key_name               = aws_key_pair.my_key.key_name 
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # we install everything we need 
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

# security group RDS 
resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "allow MySQL from ec2 only"
  vpc_id = aws_vpc.main_vpc.id 

  ingress {
    description     = "MySQL"
    from_port       = 3306 
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# DB subnet group Data base 
resource "aws_db_subnet_group" "main" { 
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS MySQL 
resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql"
  engine      = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20 

  db_name = "labdb"
  username = "admin"
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name 
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-mysql"
  }
}

# S3 Bucket 
resource "aws_s3_bucket" "main_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = var.project_name
  }
}

# Block public acces to the bucket 
resource "aws_s3_bucket_public_access_block" "main_bucket_access" {
  bucket = aws_s3_bucket.main_bucket.id

  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
}

# IAM role for EC2 
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  #trust poliy 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# IAM policy 
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.project_name}-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
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

# Instance Profile 
resource "aws_iam_instance_profile" "ec2_profile" {
   name = "${var.project_name}-ec2-profile"
   role = aws_iam_role.ec2_role.name 
}




