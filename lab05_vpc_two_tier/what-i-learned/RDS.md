# RDS — Relational Database Service

## What is it?
RDS is a managed database service from AWS. Instead of installing and maintaining a database manually on an EC2 instance, AWS handles backups, updates, availability, and scaling for you.

## Analogy
```
RDS     → the library (the service that organizes and manages everything)
MySQL   → the book (the database engine you choose)
SQL     → the language you use to read and write inside the book
```

## Supported engines
- MySQL
- PostgreSQL
- MariaDB
- Oracle
- SQL Server
- Aurora (AWS proprietary)

## Why put it in the private subnet?
Databases contain sensitive data. They should never be directly reachable from the internet. The RDS is only accessible from the EC2 instance inside the same VPC — nothing from outside can reach it.

```
Internet → ❌ cannot reach RDS directly
EC2      → ✅ can reach RDS through port 3306 (same VPC)
```

## Terraform resource
```hcl
resource "aws_db_instance" "mysql" {
  identifier        = "${var.project_name}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"     # smallest instance — good for labs
  allocated_storage = 20                # 20 GB of storage

  db_name  = "labdb"
  username = "admin"
  password = var.db_password            # sensitive variable — hidden in logs

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true   # ⚠️ only for labs — never in production
}
```

## Security Group for RDS
The RDS Security Group uses `security_groups` instead of `cidr_blocks`:

```hcl
ingress {
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.ec2.id]  # only from EC2
}
```

**Why `security_groups` instead of `cidr_blocks`?**
- `cidr_blocks` allows traffic from a specific IP — IPs can change
- `security_groups` allows traffic from any instance that has that Security Group — more secure and dynamic

## Port 3306
Standard MySQL port. Always used for MySQL connections.

## skip_final_snapshot
When destroying an RDS, AWS by default creates a backup snapshot first.
- `skip_final_snapshot = true` → skip the backup, destroy immediately
- Use `true` only in labs
- In production always use `false` — you never want to lose your data accidentally

## Key concepts
- RDS is managed — AWS handles maintenance, backups, and availability
- Always lives in the private subnet
- Requires a DB Subnet Group before it can be created
- Accessible only through its endpoint: `hostname:3306`
