# Lab 06 — IAM Role and S3 Access

## What this lab does
Deploys an EC2 instance with an IAM Role that allows it to access a private S3 bucket
without hardcoded credentials. The EC2 authenticates to S3 using an Instance Profile
that automatically provides temporary credentials.

## Infrastructure created
- S3 Bucket (private, all public access blocked)
- IAM Role for EC2
- IAM Policy (S3 read, write and list permissions)
- Trust Policy (allows EC2 service to assume the role)
- Instance Profile (connects the role to the EC2)
- EC2 instance with AWS CLI installed via user_data
- Security Group (SSH restricted to my IP only)
- Key Pair (generated locally with ssh-keygen)

## File structure

```bash
lab06_iam_s3_role/
├── main.tf           # S3 bucket, IAM role, policy, instance profile, EC2
├── providers.tf      # AWS provider and region
├── variables.tf      # Variable declarations
├── terraform.tfvars  # Variable values
├── data.tf           # Dynamic AMI and public IP
├── outputs.tf        # Public IP, bucket name and IAM role name
└── what-i-learned/   # Notes on every new concept covered in this lab
```

## Key concepts practiced
- **S3 Bucket** — object storage with globally unique bucket names
- **Public access block** — hard lock that prevents any accidental public exposure
- **IAM Role** — temporary identity assumed by EC2, no permanent credentials
- **Trust Policy** — defines who can assume the role (EC2 service in this case)
- **IAM Policy** — defines what the role can do (GetObject, PutObject, ListBucket)
- **Instance Profile** — bridge that allows EC2 to assume the IAM Role
- **Least privilege** — only the exact permissions needed, nothing more

## How to use

```bash
# 1. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f my-key-lab06

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy
terraform apply

# 5. Connect to the instance
ssh -i my-key-lab06 ec2-user@<public_ip>

# 6. Test S3 access from the instance (no credentials needed)
aws s3 ls s3://<bucket_name>
aws s3 cp test.txt s3://<bucket_name>/test.txt

# 7. Destroy when done
terraform destroy
```

## Outputs
| Name | Description |
|------|-------------|
| public_ip | EC2 public IP for SSH access |
| bucket_name | S3 bucket name |
| iam_role | IAM Role name assigned to the EC2 |
