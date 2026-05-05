# Instance Profile

## What is it?
An Instance Profile is a container that holds an IAM Role and allows an EC2 instance to assume that role.

EC2 instances cannot use IAM Roles directly — they need an Instance Profile as a bridge.

## Why is it necessary?
```
IAM Role alone → EC2 cannot use it directly
Instance Profile → wraps the role so EC2 can assume it

Without Instance Profile:
EC2 → ❌ cannot assume the role → no access to S3

With Instance Profile:
EC2 → ✅ assumes the role → has S3 permissions
```

## How it fits in the chain

```
IAM Policy         → defines what is allowed (S3 read, write, list)
    ↓ attached to
IAM Role           → holds the permissions
    ↓ wrapped in
Instance Profile   → makes the role usable by EC2
    ↓ attached to
EC2 Instance       → automatically gets temporary credentials
    ↓ uses
S3 Bucket          → accessed securely without hardcoded credentials
```

## Terraform resource
```hcl
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name   # links the role to the profile
}
```

And attached to the EC2 instance:
```hcl
resource "aws_instance" "instance-ec2" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name  # attached here
}
```

## Key concept
No hardcoded credentials — ever. Using an Instance Profile means:
- No access keys stored on the instance
- AWS automatically rotates the temporary credentials
- If the instance is compromised, the credentials expire automatically
