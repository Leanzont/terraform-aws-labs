terraform {
  backend "s3" {
    bucket         = "my-bucket-state-lean23"
    key            = "lab09_lean/terraform.tfstate" # <-- path in bucket 
    region         = "us-east-2"
    use_lockfile   = true
  }
}
