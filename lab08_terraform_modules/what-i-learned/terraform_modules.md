
---

# Terraform Modules — How and Why

## Why use modules

In Terraform, a module is a way to group related resources into a reusable, isolated unit — exactly like a function in Python. You define it once and call it with different parameters as many times as needed.

Without modules, all resources live in a single `main.tf`. This works for small labs but becomes hard to maintain, read, and reuse as infrastructure grows. Modules solve this by separating concerns — VPC logic stays in the VPC module, EC2 logic stays in the EC2 module, and so on.

The key benefits are:
- **Reusability** — call the same module with different values to deploy multiple environments (dev, staging, prod)
- **Isolation** — a change in the RDS module cannot accidentally break the VPC module
- **Readability** — the root `main.tf` reads like a high-level blueprint of the architecture

---

## How modules work

A module has three parts:

**`variables.tf`** — inputs. Values the module receives from outside. No hardcoded values.

**`main.tf`** — the resources. Uses `var.something` instead of hardcoded values.

**`outputs.tf`** — exports. The only way a module can share data with other modules or the root.

---

## How modules communicate

Modules are isolated — one module cannot read resources from another module directly. The only bridge between modules is **outputs**.

```
modules/vpc/main.tf          modules/vpc/outputs.tf        root main.tf
┌──────────────────┐         ┌──────────────────────┐      ┌─────────────────────────────┐
│ resource         │         │ output "vpc_id" {    │      │ module "rds" {              │
│ "aws_vpc"        │──.id───▶│   value =            │─────▶│   vpc_main_id =             │
│ "main_vpc"       │         │   aws_vpc.main_vpc.id│      │   module.vpc.vpc_id         │
└──────────────────┘         │ }                    │      │ }                           │
                             └──────────────────────┘      └─────────────────────────────┘
```

The RDS module cannot access `aws_vpc.main_vpc.id` directly. It receives it as a variable (`var.vpc_main_id`) whose value is set in the root `main.tf` using `module.vpc.vpc_id`. That reference only works because the VPC module explicitly declares `output "vpc_id"`.

**If there is no output declared, the value does not exist for the outside world.**

---

## Dependency chain in this lab

```
S3 ──── s3_bucket_arn ──────────────────▶ IAM
IAM ─── instance_profile ───────────────▶ EC2
VPC ─── vpc_id ─────────────────────────▶ EC2, RDS
VPC ─── public_subnet_id ───────────────▶ EC2, RDS
VPC ─── private_subnet_id ──────────────▶ RDS
EC2 ─── sg_ec2_id ──────────────────────▶ RDS
```

Terraform reads these references and automatically builds a dependency graph — it knows it must create VPC before EC2, and EC2 before RDS, without you specifying the order explicitly.

---

## Outputs have two roles depending on context

| Context | Purpose |
|--------|---------|
| Without modules | Display information on screen after `terraform apply` |
| With modules | Export values so other modules can consume them, AND display info on screen |

In this lab, `modules/vpc/outputs.tf` exports `vpc_id` so the RDS module can use it. The root `outputs.tf` also uses `module.vpc.vpc_id` to display the value on screen. Same output, two consumers.

---

