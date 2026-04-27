# Main infrastructure file - defines the core AWS resources
resource "aws_instance" "servidor" {
  # Use the most recent Amazon Linux 2 AMI from data.tf
  ami          = data.aws_ami.amazon_linux-2.id
  instance_type = var.instance_type   # <-- terraform looks for the value in .tfvars
 
  # Attach security group and key pair to the instance
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = aws_key_pair.my_key.key_name
  
  tags = {
    Name = var.proyect_name
  }

}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key-terraform-lab"
  # Read the public key from local file - private key never leaves your machine
  public_key = file("~/terraform/lab04_terraform/my-key-terraform-lab.pub")
}

resource "aws_security_group" "ssh" {
  name = "allow_ssh"
  description = "permitir trafico ssh"


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Allow SSH only from your current public IP - fetched dynamically from data.tf
    cidr_blocks  = ["${trimspace(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    # -1 means all protocols
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
