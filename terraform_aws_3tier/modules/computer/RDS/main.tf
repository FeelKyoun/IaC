terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

#Create RDS Subnet Group
resource "aws_db_subnet_group" "main_db_sn_group" {
  name       = "main_db_sn_group"
  subnet_ids = slice(var.private_subnet_id, length(var.private_subnet_id) -2, length(var.private_subnet_id))
  tags = {
    Name = "main_db_sn_group"
  }
}

#Create RDS parameter group
resource "aws_db_parameter_group" "mysql_pm_group" {
  
  name        = "mysql-custom-parameter-group"
  family      = "mysql5.7"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "innodb_file_per_table"
    value = "1"
  }
}

#Create RDS instance
resource "aws_db_instance" "rds_main" {
  identifier = "mysql-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.44"
  instance_class       = var.RDS_Instance_Class
  username             = "test"
  password             = "test1234"
  parameter_group_name = resource.aws_db_parameter_group.mysql_pm_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = resource.aws_db_subnet_group.main_db_sn_group.name
  skip_final_snapshot  = true
  multi_az             = true
  tags = {
    Name = "rds_mysql"
  }
}

#Create Security Group for RDS
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.was_sg_id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pub_sg"
  }
}






