# Create a VPC
resource "aws_vpc" "s-p2" {
  cidr_block       = "10.100.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "sahaba-vpc"
  }
}

# 
data "aws_route_table" "vpc-route-table" { # already exist
  vpc_id = aws_vpc.s-p2.id

}

resource "aws_route" "route" {
  route_table_id            = data.aws_route_table.vpc-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.s-igw.id
}

# Create a private subnet
resource "aws_subnet" "s-prs" {
  vpc_id     = aws_vpc.s-p2.id
  cidr_block = "10.100.0.0/24"
  
  tags = {
    Name = "Private-Subnet"
  }
}

# Create a Public subnet
resource "aws_subnet" "s-pbs" {
  vpc_id     = aws_vpc.s-p2.id
  cidr_block = "10.100.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public-Subnet"
  }
}

# create an Internet GW & Attach it
resource "aws_internet_gateway" "s-igw" {
  depends_on = [ aws_vpc.s-p2 ]
  vpc_id = aws_vpc.s-p2.id

  tags = {
    Name = "main"
  }
}

