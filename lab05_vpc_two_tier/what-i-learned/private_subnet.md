# Private Subnet

## What is it?
A subdivision of the VPC that has NO route to the Internet Gateway — resources inside it cannot be reached from the internet and cannot initiate connections to the internet.

## When to use it
Place resources here that should never be directly exposed to the internet:
- Databases (RDS, MySQL, PostgreSQL)
- Internal application servers
- Sensitive data storage

## What makes it "private"
The absence of two things:
1. No Route Table pointing to the Internet Gateway
2. No `map_public_ip_on_launch` — instances do not get public IPs

## Terraform resource
```hcl
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"    # different range from public subnet
  availability_zone = "us-east-2b"     # different AZ from public subnet

  tags = {
    Name = "${var.project_name}-private"
  }
}
```

## Public vs Private comparison
| | Public Subnet | Private Subnet |
|---|---|---|
| Internet access | Yes | No |
| Public IP | Auto-assigned | Never |
| Resources | EC2, Load Balancers | RDS, internal servers |
| Route to IGW | Yes | No |
| AZ in this lab | us-east-2a | us-east-2b |

## Key concepts
- Placed in `us-east-2b` — a different AZ than the public subnet
- The RDS is still reachable from the EC2 because they are in the same VPC — just not from the internet
- Different AZs provide fault tolerance — if one datacenter fails, the other keeps running
