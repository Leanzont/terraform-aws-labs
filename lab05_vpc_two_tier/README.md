# Lab 05 — VPC Two Tier Architecture

## What this lab does
Deploys a two-tier architecture on AWS using a custom VPC with public and private subnets.
The public subnet hosts an EC2 instance with nginx installed automatically,
and the private subnet hosts an RDS MySQL database accessible only from the EC2.

## Infrastructure created
- Custom VPC (10.0.0.0/16)
- Internet Gateway
- Public Subnet (10.0.1.0/24) + Route Table
- Private Subnet (10.0.2.0/24)
- EC2 instance with nginx (installed automatically via user_data)
- Security Group for EC2 (SSH restricted to my IP, HTTP open)
- Amazon RDS MySQL 8.0
- Security Group for RDS (MySQL port 3306 from EC2 only)
- DB Subnet Group
- Key Pair (generated locally with ssh-keygen)

## File structure

```bash
lab05_vpc_two_tier/
├── main.tf           # VPC, subnets, IGW, route table, SGs, EC2, RDS
├── providers.tf      # AWS provider and region
├── variables.tf      # Variable declarations
├── terraform.tfvars  # Variable values
├── data.tf           # Dynamic AMI and public IP
├── outputs.tf        # Public IP, instance ID and RDS endpoint
└── what-i-learned/   # Notes on every new concept covered in this lab
```

## Key concepts practiced
- **Custom VPC** — isolated network with a custom IP range instead of using the AWS default VPC
- **Internet Gateway** — bridge between the VPC and the internet
- **Route Table** — directs traffic from the public subnet to the Internet Gateway
- **Public vs Private subnet** — EC2 in public subnet, RDS in private subnet for security
- **Availability Zones** — subnets placed in different AZs for fault tolerance
- **user_data** — bash script that installs and starts nginx automatically on launch
- **DB Subnet Group** — required by AWS before creating any RDS instance
- **Security Group references** — RDS only accepts traffic from the EC2 Security Group
- **sensitive variable** — hides the database password from logs and terminal output

## How to use

```bash
# 1. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f my-key-lab05

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy
terraform apply

# 5. Connect to the instance
ssh -i my-key-lab05 ec2-user@<public_ip>

# 6. Verify nginx is running
http://<public_ip>

# 7. Destroy when done
terraform destroy
```

## Outputs
| Name | Description |
|------|-------------|
| public_ip | EC2 public IP for SSH and HTTP access |
| instance_id | AWS instance ID |
| RDS_end_point | RDS MySQL endpoint to connect from EC2 |
