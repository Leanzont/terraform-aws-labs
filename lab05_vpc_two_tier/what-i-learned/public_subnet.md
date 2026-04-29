# Public Subnet

## What is it?
A subdivision of the VPC that has a route to the Internet Gateway — meaning resources inside it can communicate with the internet.

## When to use it
Place resources here that need to be reachable from the internet:
- EC2 instances (web servers, SSH access)
- Load Balancers
- NAT Gateways

## What makes it "public"
Two things make a subnet public:
1. A Route Table associated with it that points `0.0.0.0/0` to the Internet Gateway
2. `map_public_ip_on_launch = true` so instances automatically get a public IP

Without both of these, the subnet is effectively private even if you call it public.

## Terraform resource
```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"    # subset of the VPC range
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true             # auto-assign public IP to instances

  tags = {
    Name = "${var.project_name}-public"
  }
}
```

## Key concepts
- `10.0.1.0/24` gives 256 IPs and fits inside the VPC range `10.0.0.0/16`
- Lives in `us-east-2a` — one Availability Zone
- `map_public_ip_on_launch = true` → instances launched here get a public IP automatically
- Security is enforced by Security Groups, not by the subnet being public
