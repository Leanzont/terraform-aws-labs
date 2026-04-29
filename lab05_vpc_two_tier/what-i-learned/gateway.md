# Internet Gateway

## What is it?
The Internet Gateway is the bridge between your VPC and the internet. By default a VPC is completely isolated — the Internet Gateway is what opens the door to the outside world.

## Analogy
```
VPC = a closed building
Internet Gateway = the front door
Route Table = the signs inside telling you where the door is
```

Without the Internet Gateway, even if your EC2 has a public IP, it cannot communicate with the internet.

## How it works
The Internet Gateway alone is not enough. You also need a Route Table that points traffic toward it. Both always work together.

```
Internet
    ↕
Internet Gateway   ← opens the connection
    ↕
Route Table        ← directs traffic toward the gateway
    ↕
Public Subnet      ← the only subnet that uses this route
```

## Terraform resource
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id   # attached to our VPC using a reference

  tags = {
    Name = var.project_name
  }
}
```

## Key concepts
- One Internet Gateway per VPC is enough
- The private subnet does NOT use the Internet Gateway — that is intentional
- Terraform automatically creates the VPC before the gateway because of the reference `aws_vpc.main.id`
