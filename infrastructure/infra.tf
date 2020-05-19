
terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}


#!Set AWS VPC as same value of var.project_name!
#!Search and replace aws_vpc.terraform_associate_env.id with updated VPC name in var.project_name!


resource "aws_vpc" "terraform_associate_env" {
  cidr_block = var.vpc_cidr 
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = "${var.project_name} VPC" } 
}



resource "aws_subnet" "vpn-subnet" {
  cidr_block        = var.vpn_subnet_cidr 
  vpc_id            = aws_vpc.terraform_associate_env.id
  availability_zone = var.vpn_az 

  tags = {
    Name = "${var.project_name } vpn-subnet"
  }
}

resource "aws_subnet" "web-subnet" {
  cidr_block        = var.web_subnet_cidr 
  vpc_id            = aws_vpc.terraform_associate_env.id
  availability_zone = var.web_az 

  tags = {
    Name = "${var.project_name } web-subnet"
  }
}

resource "aws_subnet" "mgmt-subnet" {
  cidr_block        = var.mgmt_subnet_cidr 
  vpc_id            = aws_vpc.terraform_associate_env.id
  availability_zone = var.mgmt_az 

  tags = {
    Name = "${var.project_name } mgmt-subnet"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.terraform_associate_env.id

  tags = { 
    Name = "${var.project_name} public-route-table" 
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.terraform_associate_env.id

  tags = { 
    Name = "${var.project_name} private-route-table" 
  }

}

resource "aws_route_table_association" "vpn-subnet-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.vpn-subnet.id
}

resource "aws_route_table_association" "web-subnet-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.web-subnet.id
}

resource "aws_route_table_association" "mgmt-subnet-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.mgmt-subnet.id
}

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc                       = true
  #associate_with_private_ip = "10.100.0.5"

  tags = { 
    Name = "${var.project_name} NAT GW IP" 
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.vpn-subnet.id

  tags = { 
    Name = "${var.project_name} NAT GW" 
  }

  depends_on = ["aws_eip.elastic-ip-for-nat-gw"]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_associate_env.id

  tags = { 
    Name = "${var.project_name} IGW" 
  }
}
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

