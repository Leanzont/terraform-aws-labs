# Variable declarations - values are set in terraform.tfvars
# Separating declarations from values allows multiple environments (dev, prod)

variable "region" {
  type = string 
}

variable "instance_type" {
  type = string 
}

variable "proyect_name" {
  type = string 
}

