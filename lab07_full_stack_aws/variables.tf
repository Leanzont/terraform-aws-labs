variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "project_name" {
  type = string 
}
 
variable "db_password" {
  type      = string
  sensitive = true 
}

variable "s3_bucket_name" {
  type = string 
}
