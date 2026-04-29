# Route Table

## What is it?
A set of rules (routes) that tell network traffic where to go. Every subnet in a VPC has a route table associated with it.

## Analogy
```
Internet Gateway = the front door of the building
Route Table      = the signs inside the building pointing to the door
```

The door can exist, but without signs nobody knows where it is.

## How it works
```
Route Table (public subnet):
┌─────────────────┬──────────────────────┐
│ Destination     │ Target               │
├─────────────────┼──────────────────────┤
│ 10.0.0.0/16     │ local                │  ← traffic inside VPC stays local
│ 0.0.0.0/0       │ Internet Gateway     │  ← everything else goes to internet
└─────────────────┴──────────────────────┘

Route Table (private subnet):
┌─────────────────┬──────────────────────┐
│ Destination     │ Target               │
├─────────────────┼──────────────────────┤
│ 10.0.0.0/16     │ local                │  ← only internal VPC traffic
└─────────────────┴──────────────────────┘
```

The private subnet has no route to the Internet Gateway — that is what makes it private.

## Terraform resources
```hcl
# Create the route table with a route to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                    # all internet traffic
    gateway_id = aws_internet_gateway.main.id    # goes through the gateway
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate the route table with the public subnet
# Without this the route table exists but no subnet uses it
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

## Key concepts
- The Route Table and the association are always two separate resources
- Without `aws_route_table_association` the route table is created but ignored
- `0.0.0.0/0` means "all traffic" — this is the default route to the internet
- The private subnet uses the default VPC route table which has no internet route
