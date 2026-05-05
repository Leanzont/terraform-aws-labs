# IAM — Identity and Access Management

## What is it?
IAM is the service that controls who can do what in your AWS account.
It manages identities (users, groups, roles) and their permissions (policies).

## The four core components

### Users
A user represents a person or application that needs long-term access to AWS.
- Has permanent credentials (access key + secret key)
- Can have MFA enabled
- Should follow least privilege — only the permissions they actually need

### Groups
A collection of users that share the same permissions.
- Easier to manage permissions at scale
- Example: `dev_group` → attach a policy that allows read-only access to S3

### Roles
A temporary identity that can be assumed by a service or user.
- Has no permanent credentials — AWS generates temporary ones automatically
- More secure than users for services like EC2
- Used in this lab to give EC2 access to S3

### Policies
JSON documents that define what is allowed or denied.
- Nothing in AWS can do anything without a policy attached
- Attached to users, groups, or roles

## Users vs Roles
| | User | Role |
|---|---|---|
| Credentials | Permanent (access key) | Temporary (auto-generated) |
| Used by | People, external apps | AWS services, other accounts |
| More secure | No | Yes |
| Used in this lab | No | Yes (EC2 → S3) |

## Key concept — least privilege
Always grant the minimum permissions needed and nothing more.
Never use `"Action": "*"` or `"Resource": "*"` in production.

## Terraform resource (basic role)
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
```
