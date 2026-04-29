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
