resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.project_name
  }
}

resource "aws_internet_gateway" "gw_main_vp" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-gw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_public
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone_private

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}


# route table 
resource "aws_route_table" "route_table_public_subnet" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_main_vp.id
  }

  tags = {
    Name = "${var.project_name}-route-table-public-subnet"
  }
}

# Associate route table 
resource "aws_route_table_association" "associate_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public_subnet.id
}





































# associative route table 



