module "vpc" {
  source = "./modules/vpc"

  project_name              = var.project_name
  my_ip                     = "${trimspace(data.http.my_ip.response_body)}/32"
  vpc_cidr                  = "10.0.0.0/16"
  public_subnet_cidr        = "10.0.1.0/24"
  private_subnet_cidr       = "10.0.2.0/24"
  availability_zone_public  = "us-east-2a"
  availability_zone_private = "us-east-2b"
}

module "s3" {
  source = "./modules/s3"

  project_name   = "${var.project_name}-s3"
  s3_bucket_name = var.s3_bucket_name
}

module "iam" {
  source = "./modules/iam"

  s3_bucket_arn = module.s3.s3_bucket_arn
  project_name  = "${var.project_name}-iam"
}

module "ec2" {
  source = "./modules/ec2"

  ami                   = data.aws_ami.amazon_linux_2.id # <-- data
  instance_type         = var.instance_type
  subnet_public_id      = module.vpc.public_subnet_id
  my_ip                 = "${trimspace(data.http.my_ip.response_body)}/32" # <----- data   
  vpc_id                = module.vpc.vpc_id
  instance_profile_name = module.iam.instance_profile
  project_name          = var.project_name
}

module "rds" {
  source = "./modules/rds"

  vpc_main_id       = module.vpc.vpc_id
  sg_ec2            = module.ec2.aws_sg_for_rds
  project_name      = var.project_name
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  db_password       = var.db_password

}
