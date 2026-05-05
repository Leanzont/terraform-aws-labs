# S3 Bucket — Simple Storage Service

## What is it?
S3 (Amazon Simple Storage Service) is an object storage service. You can store practically anything inside it — files, images, backups, logs, static websites, and more.

## Key rules
- **Bucket names are globally unique** — no two buckets in the entire world can share the same name
- A bucket lives in a specific AWS region
- Objects inside a bucket can be of any type and size (up to 5TB per object)

## Terminology
```
Bucket  → the container (like a folder)
Object  → what you store inside (files, images, etc.)
Key     → the name/path of the object inside the bucket
```

## Terraform resource
```hcl
resource "aws_s3_bucket" "main_bucket" {
  bucket = var.bucket_name   # must be globally unique

  tags = {
    Name = var.project_name
  }
}
```

## Key concepts
- S3 is serverless — you do not manage any servers
- By default buckets are private — nothing is publicly accessible unless you explicitly allow it
- Bucket names must be lowercase, no spaces, no underscores
- S3 has its own permission system called Bucket Policies (separate from IAM)
