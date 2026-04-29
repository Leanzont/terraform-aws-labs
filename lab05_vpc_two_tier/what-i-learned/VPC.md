# VPC — Virtual Private Cloud

## What is it?
A VPC is a virtual private network inside AWS. Think of it as your own isolated building inside the AWS cloud — nothing gets in or out unless you explicitly allow it.

Every AWS resource (EC2, RDS, etc.) lives inside a VPC.

## Why is it important?
Without a VPC you have no network isolation — your resources would be exposed by default. The VPC is the foundation that everything else is built on top of.

## How it works
You define a main IP range (CIDR block) for the VPC, then create smaller subnets from that range.

```
VPC 10.0.0.0/16  →  65,536 available IPs
├── Public Subnet   10.0.1.0/24  (256 IPs)
└── Private Subnet  10.0.2.0/24  (256 IPs)
```

## Terraform resource
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true   # instances get a DNS name automatically
  enable_dns_support   = true   # enables DNS resolution inside the VPC

  tags = {
    Name = var.project_name
  }
}
```

## Key concepts
- `/16` gives 65,536 IPs — enough for a real production environment
- Subnets are subdivisions of the VPC — they cannot exceed the VPC CIDR range
- A VPC spans an entire AWS region
- Subnets live inside a single Availability Zone
