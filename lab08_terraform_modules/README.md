
```markdown
# 🧱 Lab 08 — Terraform Modules

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Provider-orange.svg)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 What this lab does

This lab refactors the full stack architecture from **Lab 07** into reusable Terraform modules. The infrastructure deployed is identical — VPC, EC2, RDS, S3, and IAM — but the code is now organized into isolated, reusable modules that communicate through outputs.

## 🏗️ Infrastructure created

Same **17 resources** as Lab 07, now split across **5 modules**:

- **vpc** — VPC, Internet Gateway, public and private subnets, route table and association
- **ec2** — Security Group, Key Pair, EC2 instance with nginx and AWS CLI via user_data
- **rds** — Security Group, DB Subnet Group, RDS MySQL 8.0
- **s3** — S3 Bucket, public access block
- **iam** — IAM Role, Trust Policy, IAM Policy, Instance Profile

## 📁 Module structure

```
lab08_terraform_modules/
├── data.tf                   # Dynamic AMI and public IP
├── main.tf                   # Root — calls all modules
├── providers.tf              # AWS provider
├── variables.tf              # Root variable declarations
├── terraform.tfvars          # Root variable values
├── outputs.tf                # Final outputs shown after apply
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── rds/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── iam/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 🔄 How modules communicate

Modules are isolated — one module cannot read resources from another directly. The only way to pass data between modules is through **outputs**.

```
S3  ──── s3_bucket_arn ─────────────────▶ IAM
IAM ──── instance_profile ──────────────▶ EC2
VPC ──── vpc_id ────────────────────────▶ EC2, RDS
VPC ──── public_subnet_id ──────────────▶ EC2, RDS
VPC ──── private_subnet_id ─────────────▶ RDS
EC2 ──── sg_ec2_id ─────────────────────▶ RDS
RDS ──── (no exports)
```

Terraform reads these references and automatically builds a **dependency graph** — it knows it must create VPC before EC2, and EC2 before RDS, without specifying the order explicitly.

## 🧠 Key concepts learned

- **Module structure** — every module has `main.tf`, `variables.tf`, and `outputs.tf`
- **Variables as inputs** — modules receive values from the root via variables, no hardcoded values inside modules
- **Outputs as exports** — the only way a module shares data with other modules or the root
- **Module references** — `module.vpc.vpc_id` only works if `output "vpc_id"` is declared inside the vpc module
- **Dependency graph** — Terraform resolves creation order automatically based on references
- **Reusability** — the same module can be called multiple times with different values to deploy different environments

## 🚀 How to use

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.5+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- SSH key generation tool

### Deployment steps

```bash
# 1. Generate SSH key pair inside modules/ec2/
ssh-keygen -t rsa -b 4096 -f modules/ec2/my-key-lab08

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy infrastructure
terraform apply

# 5. Verify nginx is running
curl http://<public_ip>

# 6. Connect to the instance
ssh -i modules/ec2/my-key-lab08 ec2-user@<public_ip>

# 7. Test S3 access from the instance
aws s3 ls s3://<bucket_name>

# 8. Destroy when done
terraform destroy
```

## 📤 Outputs

| Name | Description |
|------|-------------|
| `public_ip` | EC2 public IP for SSH and HTTP access |
| `instance_id` | AWS instance ID |
| `bucket_name` | S3 bucket name |
| `iam_role` | IAM instance profile name |
| `RDS_end_point` | RDS MySQL endpoint |

## 📊 Resources created — 17 total

| Resource | Count |
|----------|-------|
| VPC | 1 |
| Internet Gateway | 1 |
| Subnets | 2 |
| Route Table + Association | 2 |
| Security Groups | 2 |
| EC2 Instance + Key Pair | 2 |
| RDS + DB Subnet Group | 2 |
| S3 Bucket + Public Access Block | 2 |
| IAM Role + Policy + Instance Profile | 3 |

## 🆚 Difference vs Lab 07

| Aspect | Lab 07 | Lab 08 |
|--------|--------|--------|
| **Structure** | Single `main.tf` with all resources | 5 isolated modules |
| **Reusability** | Copy and modify entire file | Call module with different variables |
| **Readability** | 200+ lines in one file | Root `main.tf` is a clean blueprint |
| **Data sharing** | Direct resource references | Explicit outputs between modules |

