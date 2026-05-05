# IAM Policies

## What is a policy?
A JSON document that defines what actions are allowed or denied, on which resources, and under what conditions.

Without a policy attached, no user, group, or role can do anything in AWS.

## Policy structure — always the same 4 fields

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":    "Allow or Deny",
      "Principal": "who (only in trust policies)",
      "Action":    "what actions",
      "Resource":  "on which resources"
    }
  ]
}
```

## Each field explained

**Effect**
```
Allow → permits the action
Deny  → blocks the action (always wins over Allow)
```

**Principal** (only in trust policies)
```json
{ "Service": "ec2.amazonaws.com" }                        → AWS service
{ "AWS": "arn:aws:iam::123456789012:root" }               → entire AWS account
{ "AWS": "arn:aws:iam::123456789012:user/leandro" }       → specific user
```

**Action**
```json
"s3:GetObject"     → read a specific object
"s3:PutObject"     → upload an object
"s3:ListBucket"    → list contents of a bucket
"s3:*"             → all S3 actions (avoid in production)
"*"                → everything in AWS (never use this)
```

**Resource**
```json
"*"                                  → all resources (avoid)
"arn:aws:s3:::my-bucket"            → specific bucket
"arn:aws:s3:::my-bucket/*"          → all objects inside bucket
```

## Types of policies

**AWS Managed Policies** — pre-built by AWS
```
AmazonS3ReadOnlyAccess   → read-only access to all S3 buckets
AmazonEC2FullAccess      → full access to EC2
AdministratorAccess      → full access to everything (never use in production)
```

**Inline Policies** — written by you, attached directly to a role or user
```
More specific, more control
Used in this lab for the S3 permissions
```

## Key rule — Deny always wins
```
Allow + Deny on the same action = DENY
```
If a user has an Allow policy and a Deny policy for the same action, AWS always denies it.

## Least privilege principle
Always grant the minimum permissions needed and nothing more.
Start with zero permissions and add only what is required.
