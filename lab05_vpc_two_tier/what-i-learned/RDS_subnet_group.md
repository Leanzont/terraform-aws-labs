# DB Subnet Group

## What is it?
A DB Subnet Group is an AWS requirement before creating any RDS instance. It tells AWS which subnets are available for the database to live in.

## Why does it need two subnets?
AWS requires a minimum of two subnets in **different Availability Zones**. This is so AWS can automatically move the database to another AZ if one datacenter fails.

```
DB Subnet Group
├── Public Subnet   10.0.1.0/24  (us-east-2a)   ← AZ A
└── Private Subnet  10.0.2.0/24  (us-east-2b)   ← AZ B

AWS places the RDS in one of these subnets
→ in this lab it uses the private subnet because the Security Group is configured there
```

## Does the RDS use both subnets at the same time?
No. The RDS lives in one subnet. The second subnet is a standby option for AWS in case of AZ failure. Think of it as telling AWS: *"here are your options — pick one and keep the other as backup"*.

## Terraform resource
```hcl
resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  # Both subnets provided — AWS requires at least 2 in different AZs
  subnet_ids = [
    aws_subnet.public.id,   # us-east-2a
    aws_subnet.private.id   # us-east-2b
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}
```

## Key concepts
- Required by AWS before any RDS can be created
- Minimum two subnets in different Availability Zones
- The RDS does not use both subnets simultaneously — one is active, one is standby
- The actual subnet where RDS ends up depends on the Security Group and configuration
- Without this resource `terraform apply` will fail when trying to create the RDS
