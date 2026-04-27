# Data sources - query existing information without creating resources

# Fetch the most recent Amazon Linux 2 AMI automatically
# Avoids hardcoding AMI IDs which change per region and expire
data "aws_ami" "amazon_linux-2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Fetch your current public IP to restrict SSH access
# trimspace() removes the newline character from the response
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}


