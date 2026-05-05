# S3 Bucket Security — Public Access Block

## What is it?
A separate resource that explicitly blocks all public access to an S3 bucket.
Even if someone tries to make the bucket public through a bucket policy or ACL, this block overrides it.

## Why is it important?
By default S3 buckets are private, but AWS allows you to override that.
The `aws_s3_bucket_public_access_block` resource acts as a hard lock — it prevents any accidental or intentional public exposure.

In this lab the EC2 accesses the bucket through an IAM Role, so the bucket never needs to be public.

## Terraform resource
```hcl
resource "aws_s3_bucket_public_access_block" "main_bucket" {
  bucket = aws_s3_bucket.main_bucket.id

  block_public_acls       = true   # blocks public ACLs from being set
  block_public_policy     = true   # blocks public bucket policies
  ignore_public_acls      = true   # ignores any existing public ACLs
  restrict_public_buckets = true   # restricts public access even if policy allows it
}
```

## What each parameter does
| Parameter | What it blocks |
|---|---|
| `block_public_acls` | Prevents setting public ACLs on the bucket or objects |
| `block_public_policy` | Prevents attaching a bucket policy that grants public access |
| `ignore_public_acls` | Ignores any public ACLs that already exist |
| `restrict_public_buckets` | Blocks public and cross-account access even if a policy allows it |

## Key concept
Public and accessible are two different things:
```
Public     → anyone on the internet can access it
Accessible → specific services or users with the right permissions can access it

The bucket in this lab is NOT public but IS accessible — only from the EC2 via IAM Role
```
