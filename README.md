# Terraform AWS Labs
Personal AWS infrastructure labs built with Terraform as part of a self-directed cloud engineering learning path.
Each lab focuses on a specific concept, building on the previous one.

## Labs

| Lab | Description | Concepts |
|-----|-------------|----------|
| [Lab 04 — Modular Structure](./lab04_terraform_modular/) | EC2 instance with modular Terraform file structure | Data sources, variables, outputs, dynamic AMI and IP |
| [Lab 05 — VPC Two Tier](./lab05_vpc_two_tier/) | Two-tier architecture with public and private subnets | VPC, Internet Gateway, Route Table, RDS MySQL, user_data, Security Group references |
| [Lab 06 — IAM Role and S3](./lab06_iam_s3_role/) | EC2 accessing a private S3 bucket using an IAM Role | IAM Role, Trust Policy, IAM Policy, Instance Profile, S3, least privilege |
| [Lab 07 — Full Stack AWS](./lab07_full_stack_aws/) | Complete architecture combining all core AWS services | VPC, EC2, RDS, S3, IAM, Internet Gateway, Route Table, Security Groups, Instance Profile |
| [Lab 08 — Terraform Modules](./lab08_terraform_modules/) | Lab 07 refactored into reusable Terraform modules | Modules, inputs, outputs as exports, inter-module communication, dependency graph |

## Tech stack
- Terraform
- AWS (EC2, RDS, S3, VPC, IAM, Security Groups, Key Pairs, Internet Gateway, Route Tables)
- Linux (Arch)

## Goals
Building a solid foundation in cloud infrastructure to work remotely
for international companies as a Cloud/DevOps Engineer.
