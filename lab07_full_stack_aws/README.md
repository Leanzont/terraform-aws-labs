# Lab 07 — Full Stack AWS Architecture

## What this lab does
This lab brings together everything learned in previous labs into a single, production-like architecture.
It deploys a custom VPC with public and private subnets, an EC2 instance running nginx,
a private RDS MySQL database, a private S3 bucket, and an IAM Role that gives the EC2
secure access to S3 without hardcoded credentials.

## Infrastructure created
- Custom VPC (10.0.0.0/16) with DNS support enabled
- Internet Gateway — connects the VPC to the internet
- Public Subnet (10.0.1.0/24 — us-east-2a) with auto-assigned public IPs
- Private Subnet (10.0.2.0/24 — us-east-2b) for sensitive resources
- Route Table — directs public subnet traffic to the Internet Gateway
- Security Group for EC2 (SSH restricted to my IP, HTTP open to all)
- EC2 instance with nginx and AWS CLI installed automatically via user_data
- Key Pair (generated locally with ssh-keygen)
- Security Group for RDS (MySQL port 3306 accessible from EC2 only)
- DB Subnet Group (required by AWS before creating any RDS)
- RDS MySQL 8.0 in the private subnet
- S3 Bucket (private, all public access blocked)
- IAM Role with Trust Policy (allows EC2 to assume the role)
- IAM Policy (S3 read, write, and list permissions)
- Instance Profile (connects the IAM Role to the EC2 instance)

## Architecture

```
Internet
    ↕
Internet Gateway
    ↕
VPC 10.0.0.0/16
├── Public Subnet 10.0.1.0/24 (us-east-2a)
│   └── EC2 Instance
│       ├── nginx (web server)
│       ├── AWS CLI
│       ├── Security Group → SSH (my IP only), HTTP (open)
│       ├── IAM Role → S3 access without credentials
│       └── Instance Profile
└── Private Subnet 10.0.2.0/24 (us-east-2b)
    └── RDS MySQL 8.0
        └── Security Group → port 3306 from EC2 only

S3 Bucket (private)
└── accessible only from EC2 via IAM Role
```

## File structure

```bash
lab07_full_stack_aws/
├── main.tf           # All AWS resources
├── providers.tf      # AWS provider and region
├── variables.tf      # Variable declarations
├── terraform.tfvars  # Variable values
├── data.tf           # Dynamic AMI and public IP
└── outputs.tf        # Public IP, instance ID, bucket name, IAM role, RDS endpoint
```

## Key concepts combined in this lab
- **Custom VPC** — isolated network, not the AWS default
- **Public vs Private subnet** — EC2 in public, RDS in private for security
- **Internet Gateway + Route Table** — always work together to enable internet access
- **user_data** — bash script that installs nginx and AWS CLI automatically on launch
- **Security Group references** — RDS only accepts traffic from the EC2 Security Group
- **DB Subnet Group** — required by AWS, needs two subnets in different AZs
- **IAM Role + Trust Policy** — defines what the role can do and who can assume it
- **Instance Profile** — the bridge that allows EC2 to assume the IAM Role
- **Least privilege** — S3 policy only allows GetObject, PutObject and ListBucket on the specific bucket
- **No hardcoded credentials** — EC2 accesses S3 through the IAM Role automatically

## How to use

```bash
# 1. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f my-key-lab07

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy
terraform apply

# 5. Verify nginx is running
http://<public_ip>

# 6. Connect to the instance
ssh -i my-key-lab07 ec2-user@<public_ip>

# 7. Test S3 access from the instance (no credentials needed)
aws s3 ls s3://<bucket_name>
aws s3 cp test.txt s3://<bucket_name>/test.txt

# 8. Destroy when done
terraform destroy
```

## Outputs
| Name | Description |
|------|-------------|
| public_ip | EC2 public IP for SSH and HTTP access |
| instance_id | AWS instance ID |
| bucket_name | S3 bucket name |
| iam_role | IAM Role name assigned to the EC2 |
| RDS_end_point | RDS MySQL endpoint to connect from EC2 |

## Resources created — 17 total
| Resource | Count |
|---|---|
| VPC | 1 |
| Internet Gateway | 1 |
| Subnets | 2 |
| Route Table + Association | 2 |
| Security Groups | 2 |
| EC2 Instance + Key Pair | 2 |
| RDS + DB Subnet Group | 2 |
| S3 Bucket + Public Access Block | 2 |
| IAM Role + Policy + Instance Profile | 3 |
