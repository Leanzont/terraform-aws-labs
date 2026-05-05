# IAM Roles and Policies

## How to build a role — the correct order

```
1. Create the role (empty by default)
2. Attach the Trust Policy (who can assume it)
3. Attach the IAM Policy (what it can do)
4. Attach to an Instance Profile (so EC2 can use it)
```

A role without a policy can be assumed but cannot do anything.
A policy without a role attached to a resource does nothing.

## IAM Policy — what the role can do

The policy defines the specific actions allowed and on which resources.

```hcl
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.project_name}-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",    # read objects
          "s3:PutObject",    # write objects
          "s3:ListBucket"    # list bucket contents
        ]
        Resource = [
          aws_s3_bucket.main_bucket.arn,        # the bucket itself (for ListBucket)
          "${aws_s3_bucket.main_bucket.arn}/*"  # objects inside (for Get and Put)
        ]
      }
    ]
  })
}
```

## Why two Resource entries?
S3 has two distinct resource levels:
```
Bucket level  → arn:aws:s3:::my-bucket      → required for s3:ListBucket
Object level  → arn:aws:s3:::my-bucket/*    → required for s3:GetObject and s3:PutObject
```
Without both entries some actions would be denied even with the policy attached.

## Trust Policy — who can assume the role

```hcl
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }  # only EC2 can assume this role
      Action    = "sts:AssumeRole"
    }
  ]
})
```

The Trust Policy works like a security guard at the door — it decides who is allowed to enter and assume the role. Even if someone has the right policy, if they are not in the Trust Policy they cannot assume the role.

## Key concept
```
IAM Policy   → what the role can DO
Trust Policy → who can ASSUME the role

Both are required for the role to work correctly
```
