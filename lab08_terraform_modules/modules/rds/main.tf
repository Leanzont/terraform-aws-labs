# security group RDS 
resource "aws_security_group" "rds_sg" {
  name = "${var.project_name}-rds-sg"
  description = "allow MySQL from ec2 only"
  vpc_id = var.vpc_main_id

  ingress {
    description = "MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [var.sg_ec2]
  }

  egress {
    from_port = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }

}

# db subnet group data base  
resource "aws_db_subnet_group" "main_db_subnet" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = [var.public_subnet_id, var.private_subnet_id]

  tags = {
    Name = "${var.project_name}-subnet-group"
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

  db_subnet_group_name = aws_db_subnet_group.main_db_subnet.name 
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true 

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
