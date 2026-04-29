# principal VPC 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true 
  enable_dns_support   = true

  tags = {
    Name = var.project_name
  }
}

# internet Gateway 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id 

  tags = {
    Name = var.project_name
  }
}

# public subnet 
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a" 
  map_public_ip_on_launch = true  # <--- automatically assigns the public IP

  tags = {
    Name = "${var.project_name}-public"
  }
}

# private subnet 
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id 
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b" 

  tags = {
    Name = "${var.project_name}-private"
  }
}

# Route Table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id 
  }

  tags = {
    Nmae = "${var.project_name}-public-rt"
  }
}

# Associate the Route Table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

}

# Securit group ec2 
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

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
    Name = "${var.project_name}-ec2-sg"
  }
}

# Key-pair 
resource "aws_key_pair" "my_key" {
  key_name   = "my-key-lab05"
  public_key = file("~/terraform/lab05_terraform/my-key-lab05.pub")
}


# EC2 in public subnet 
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id 
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id 
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.my_key.key_name

  # Install nginx automatically when launching the instance
  user_data = <<-EOF
                #!/bin/bash 
                yum update -y
                yum install -y nginx
                systemctl start nginx
                systemctl enable nginx
                EOF
  
  tags = {
    Name = "${var.project_name}-web"
  } 
}


# Security group RDS 
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "allow MySQL from EC2 only"
  vpc_id      = aws_vpc.main.id 

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
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

# DB Subnet Group 
resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS MySQL
resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
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
