# Lab 09 — Remote State with S3 and DynamoDB

## What this lab does
This lab introduces Terraform Remote State — the production-standard way to store
and manage the `terraform.tfstate` file. Instead of keeping state on a local machine,
this lab configures an S3 bucket as the state backend and a DynamoDB table as the
state lock mechanism, making the setup safe for teams and resilient to machine failure.

## Why remote state matters

Terraform uses `terraform.tfstate` as a map of everything it has created in AWS.
Without it, Terraform does not know what resources exist and will try to create
duplicates or throw errors.

Storing this file locally creates three critical problems:

| Problem | Consequence |
|---------|-------------|
| Machine failure | The state file is lost — Terraform loses track of all resources |
| Multiple engineers | Each person has a different version of the state — conflicts and corruption |
| Simultaneous applies | One apply overwrites the other's state — infrastructure gets corrupted |

Remote State solves all three by centralizing the state file in S3 and using
DynamoDB to prevent simultaneous applies.

## How the backend works

```
Engineer 1 ──apply──▶ DynamoDB (lock check) ──▶ S3 (read/write tfstate)
Engineer 2 ──apply──▶ DynamoDB (lock check) ──▶ ERROR: state locked, try again later
```

**S3** stores the `terraform.tfstate` file in a central, durable location accessible
by any machine or engineer with the right credentials.

**DynamoDB** acts as a lock verifier. Before any apply touches the state file,
Terraform writes a lock entry to DynamoDB. If another apply tries to run at the same
time, Terraform detects the lock and blocks it until the first apply finishes.

The DynamoDB table **must** use `LockID` as the partition key — this is hardcoded
into Terraform's source code and cannot be changed.

## What gets created manually vs by Terraform

The S3 bucket and DynamoDB table must be created **before** running Terraform,
because Terraform needs the backend to exist before it can store any state.
This is a chicken-and-egg problem — Terraform cannot create the bucket it needs
to store the state of creating the bucket.

```
Terraform init
    ↓
Looks for S3 backend
    ↓
Bucket does not exist yet → ERROR
```

Solution: create the backend infrastructure manually with the AWS CLI first,
then configure Terraform to use it.

## Infrastructure created

### Manually via AWS CLI (backend)
- S3 bucket — stores `terraform.tfstate`
- DynamoDB table — provides state locking

### Via Terraform apply (lab resources)
- Security Group — SSH access restricted to my IP
- Key Pair — for EC2 SSH access
- EC2 instance — Amazon Linux 2

## File structure

```
lab09_remote_state/
├── backend.tf        # S3 backend and DynamoDB lock configuration
├── providers.tf      # AWS provider
├── data.tf           # Dynamic AMI and public IP
├── main.tf           # EC2, Security Group, Key Pair
├── variables.tf      # Variable declarations
└── terraform.tfvars  # Variable values
```

## Key file — backend.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "my-bucket-state-lean23"
    key            = "lab09_lean/terraform.tfstate"  # path inside the bucket
    region         = "us-east-2"
    dynamodb_table = "terraform-lock"
  }
}
```

The `key` is the path **inside** the bucket where the tfstate will be stored —
not a local path, not the bucket name. This allows a single bucket to store
state for multiple projects:

```
my-bucket-state-lean23/
├── lab09/terraform.tfstate
├── lab10/terraform.tfstate
└── production/terraform.tfstate
```

## How to use

```bash
# 1. Create the S3 bucket manually
aws s3api create-bucket \
  --bucket my-bucket-state-lean23 \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2

# 2. Create the DynamoDB table manually
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2

# 3. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f my-key-lab09

# 4. Initialize Terraform — connects to the S3 backend
terraform init

# 5. Preview changes
terraform plan

# 6. Deploy
terraform apply

# 7. Verify tfstate is stored in S3
aws s3 ls s3://my-bucket-state-lean23/lab09_lean/

# 8. Verify DynamoDB lock record
aws dynamodb scan --table-name terraform-lock --region us-east-2

# 9. Destroy lab resources
terraform destroy

# 10. Clean up backend (manual — not managed by Terraform)
aws s3 rm s3://my-bucket-state-lean23 --recursive
aws s3api delete-bucket --bucket my-bucket-state-lean23 --region us-east-2
aws dynamodb delete-table --table-name terraform-lock --region us-east-2
```

## What terraform init outputs with a remote backend

```
Initializing the backend...
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

This line confirms that Terraform is no longer storing state locally.
Without a remote backend, this line does not appear.

## What gets stored in DynamoDB

After a successful apply, DynamoDB keeps an MD5 checksum of the state file
to verify integrity:

```json
{
  "LockID": "my-bucket-state-lean23/lab09_lean/terraform.tfstate-md5",
  "Digest": "ec604b09b1c0f7ac0dd71f8a77d3888e"
}
```

During an active apply, DynamoDB also stores who holds the lock,
when it was acquired, and what operation is running.

## What happens if you lose the tfstate

If the state file is deleted from S3, Terraform loses its map of existing resources.
Running `terraform apply` again will attempt to create all resources from scratch,
which will either fail (if resources already exist with the same names) or create
duplicates (if AWS allows it). Recovery requires manually importing each resource
back into the state using `terraform import` — a slow and error-prone process.

This is why the S3 backend is configured with versioning in production environments,
allowing state file recovery from a previous version.

## Key concepts learned in this lab

- **Remote State** — centralized tfstate accessible by any machine or engineer
- **S3 backend** — durable, versioned storage for the state file
- **DynamoDB locking** — prevents simultaneous applies from corrupting state
- **LockID** — hardcoded partition key required by Terraform, not configurable
- **PAY_PER_REQUEST billing** — correct choice for DynamoDB lock tables with low, unpredictable traffic
- **Backend must exist before init** — the S3 bucket and DynamoDB table must be created manually before running Terraform
- **key parameter** — the internal path inside the bucket, not a local path

## Difference vs previous labs

| | lab04 – lab08 | lab09 |
|--|---------------|-------|
| tfstate location | Local machine | S3 bucket |
| Team safety | None — conflicts guaranteed | DynamoDB lock prevents conflicts |
| Machine failure | State lost | State safe in S3 |
| Simultaneous applies | State corruption | Blocked by lock |
| backend.tf | Not present | Required |
