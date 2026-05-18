variable "vpc_main_id" {
  type = string
}
variable "sg_ec2" {
  type = string 
}
variable "project_name" {
  type = string 
}
variable "public_subnet_id" {
  type = string
} 
variable "private_subnet_id" {
  type = string
} 
variable "db_password" {
  type      = string
  sensitive = true 
}

