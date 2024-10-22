terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}



# Calculate the number of bits needed to represent the total number of subnets in binary

locals {
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  total_subnets_count = local.public_subnet_count + local.private_subnet_count
  additional_bits     = ceil(log(local.total_subnets_count, 2) / log(2, 2))
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "TEST"
  }
}

#Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = resource.aws_vpc.main_vpc.id

  tags = {
    Name = "igw"
  }
}

#Create Elastic IP for NAT Gateway
resource "aws_eip" "ngw_eip" {
  domain = "vpc"
}

#Create NAT Gateway
resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.ngw_eip.id
  connectivity_type = "public"
  tags = {
    Name = "NAT"
  }

  depends_on = [resource.aws_internet_gateway.igw]
}

# Create routing table for Public Access
resource "aws_route_table" "public_table" {
  vpc_id = resource.aws_vpc.main_vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }  
}

# Create Routing table for private Access
resource "aws_route_table" "private_table" {
  vpc_id = resource.aws_vpc.main_vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = resource.aws_nat_gateway.ngw.id
  }  
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  count      = var.public_subnet_count
  vpc_id     = resource.aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(resource.aws_vpc.main_vpc.cidr_block, local.additional_bits, count.index)
  availability_zone = count.index % 2 == 0 ? "ap-northeast-2a" : "ap-northeast-2c"
  tags = {
    Name = "Public_Subnet_${count.index + 1}"
  }
}

# Associate Public Subnet with Public Routing Table
resource "aws_route_table_association" "public_association" {
  count         = length(aws_subnet.public_subnet)
  subnet_id     = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_table.id
}

#Create Private Subnet
resource "aws_subnet" "private_subnet" {
  count      = var.private_subnet_count
  vpc_id     = resource.aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(resource.aws_vpc.main_vpc.cidr_block, local.additional_bits, count.index + var.public_subnet_count )
  availability_zone = count.index % 2 == 0 ? "ap-northeast-2a" : "ap-northeast-2c"
  tags = {
    Name = "Private_Subnet_${count.index + 1}"
  }
}

# Associate Private Subnet with Private Routing Table`
resource "aws_route_table_association" "private_association" {
  count         = length(aws_subnet.priaws_route_table_associationvate_subnet)
  subnet_id     = aws_subnet.private_subnet[count.index].id
  route_table_id = resource.aws_route_table.private_table.id
}


