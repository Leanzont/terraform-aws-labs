variable "project_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "region" {
  type = string
}
