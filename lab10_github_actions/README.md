# Lab 10 — GitHub Actions CI/CD

## What this lab does
This lab implements a CI/CD pipeline using GitHub Actions that automatically verifies
Terraform code on every push to main. Instead of running `terraform fmt`, `validate`,
and `plan` manually on a local machine, GitHub runs them automatically in a temporary
Ubuntu VM every time code changes are pushed to the repository.

## Where the workflow lives
```
terraform-aws-labs/
└── .github/
    └── workflows/
        └── terraform.yml
```
GitHub requires workflows to live in `.github/workflows/` — this is not configurable.

## How GitHub Actions works

GitHub Actions creates a temporary Ubuntu VM, runs every step defined in the `.yml` file,
and destroys the VM when finished. The VM has no memory of previous runs — every workflow
starts from zero.

```
push to main
     ↓
GitHub creates a temporary Ubuntu VM
     ↓
VM clones the repository
     ↓
VM installs Terraform
     ↓
VM configures AWS credentials from GitHub Secrets
     ↓
VM runs: init → fmt → validate → plan
     ↓
VM is destroyed
```

## CI/CD explained

**CI — Continuous Integration**
Automatically verifies every code change before it reaches production.
Catches formatting errors, syntax errors, and invalid configurations before they cause damage.

**CD — Continuous Delivery**
Automatically deploys infrastructure when approved code is merged to main.
In this lab only CI is implemented — the `terraform apply` step is intentionally left manual.

## The real team workflow

In a professional environment, nobody pushes directly to main. Every change goes through
a branch and a Pull Request:

```
Engineer creates a branch
     ↓
makes changes and pushes
     ↓
CI runs automatically — fmt, validate, plan
     ↓
another engineer reviews the code — human review
     ↓
PR is approved and merged to main
     ↓
CD runs terraform apply automatically
```

The double verification — automated CI check plus human review — ensures no broken
or poorly designed code reaches production infrastructure.

## GitHub Secrets

The VM needs AWS credentials to run `terraform plan`, but credentials must never
be stored in code. GitHub Secrets solves this — credentials are encrypted and stored
in GitHub, then injected into the VM at runtime:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-2
```

Secrets configured in this lab:
| Secret | Purpose |
|--------|---------|
| `AWS_ACCESS_KEY_ID` | AWS authentication |
| `AWS_SECRET_ACCESS_KEY` | AWS authentication |
| `TF_PUBLIC_KEY` | SSH public key for EC2 key pair |

## The workflow file

```yaml
name: Terraform CI

on:
  push:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2

      - name: Create SSH public key file
        run: |
          echo "${{ secrets.TF_PUBLIC_KEY }}" > lab09_remote_state/my-key-lab09.pub

      - name: Terraform Init
        working-directory: lab09_remote_state
        run: terraform init

      - name: Terraform Format
        working-directory: lab09_remote_state
        run: terraform fmt -check

      - name: Terraform Validate
        working-directory: lab09_remote_state
        run: terraform validate

      - name: Terraform Plan
        working-directory: lab09_remote_state
        run: terraform plan -var="project_name=lab09-remote-state" -var="instance_type=t2.micro" -var="region=us-east-2"
```

## Key concepts learned in this lab

- **GitHub Actions** — CI/CD platform integrated directly into GitHub
- **Workflow trigger** — the `on: push: branches: main` block defines when the workflow runs
- **Jobs and steps** — a job is a group of steps that run on the same VM
- **runs-on** — defines the operating system of the VM
- **working-directory** — tells the VM which folder to run commands in
- **GitHub Secrets** — encrypted storage for sensitive values, injected at runtime
- **uses vs run** — `uses` calls a pre-built GitHub Action, `run` executes a shell command
- **Ephemeral VM** — the VM is created fresh for every run and destroyed when finished

## Why this matters professionally

Every professional infrastructure team uses CI/CD. Without it:
- Deployments are manual and prone to human error
- There is no automatic verification before code reaches production
- Team members cannot see what changes are being made or whether they are safe

With CI/CD, the process is always identical, always automatic, and always visible to the entire team.

## Difference vs previous labs

| | lab04 — lab09 | lab10 |
|--|---------------|-------|
| Where code runs | Local machine | GitHub VM |
| Verification | Manual | Automatic on every push |
| Team visibility | None | Full — everyone sees the workflow |
| Credential handling | Local tfvars | GitHub Secrets |
| Deploy trigger | Manual terraform apply | Automatic on merge to main |
