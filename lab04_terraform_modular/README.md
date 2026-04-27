```markdown
# Lab 04 — Modular Terraform Structure

## What this lab does
Deploys an EC2 instance on AWS using a modular Terraform structure.
Instead of putting everything in one file, the configuration is split
into separate files by responsibility.

## Infrastructure created
- EC2 instance (Amazon Linux 2)
- Security Group (SSH access restricted to my public IP only)
- Key Pair (generated locally with ssh-keygen)

## File structure

```bash
lab04_terraform_modular/
├── main.tf           # Core AWS resources
├── providers.tf      # AWS provider and region
├── variables.tf      # Variable declarations
├── terraform.tfvars  # Variable values
├── data.tf           # Dynamic data sources (AMI and public IP)
└── outputs.tf        # Public IP and instance ID after apply
```

## Key concepts practiced
- **Data sources** — fetch the latest Amazon Linux 2 AMI automatically instead of hardcoding it
- **Dynamic IP** — uses checkip.amazonaws.com to restrict SSH access to my current IP only
- **Variable separation** — declarations in variables.tf, values in terraform.tfvars
- **Resource references** — connecting resources using TYPE.NAME.attribute syntax

## How to use
```bash
# 1. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f my-key-terraform-lab

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy
terraform apply

# 5. Connect to the instance
ssh -i my-key-terraform-lab ec2-user@<public_ip>

# 6. Destroy when done
terraform destroy
```

## Outputs
| Name | Description |
|------|-------------|
| public_ip | Instance public IP for SSH access |
| instance_id | AWS instance ID |
```

