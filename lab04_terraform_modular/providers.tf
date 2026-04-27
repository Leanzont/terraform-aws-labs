# Defines which cloud provider Terraform will use
# Region value comes from variables.tf / terraform.tfvars
provider "aws" {
  region = var.region   
}
