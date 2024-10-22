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

# Amazon Linux 2 data source

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


# Create Instance for Bastion Host
resource "aws_instance" "bastion_host" {
  ami             = data.aws_ami.amazon_linux.id
  subnet_id       = var.bastion_host_sn
  instance_type   = var.EC2_Instance_Type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "bastion_host"
  }
}

# Create template sample for web server
resource "aws_launch_template" "web_template" {
  name_prefix        = "web-template"
  image_id           = data.aws_ami.amazon_linux.id
  instance_type      = var.Template_Instance_Type
  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    subnet_id                   = var.web_template_pri_subnet_id
    security_groups = [resource.aws_security_group.web_sg.id]
  }
  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 40
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-instance"
    }
  }
}

# Create autoscaling group sample for web server
resource "aws_autoscaling_group" "web_group" {
  name               = "web_asg_group"
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns    = var.web_target_group_arns
  vpc_zone_identifier  = var.web_private_subnet_id_list
  
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
  timeouts {
    delete = "15m"
  }  
  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create template sample for was server
resource "aws_launch_template" "was_template" {
  name_prefix        = "was-template"
  image_id           = data.aws_ami.amazon_linux.id
  instance_type      = var.Template_Instance_Type
  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    subnet_id                   = var.was_template_pri_subnet_id
    security_groups = [resource.aws_security_group.was_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 40
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "was-instance"
    }
  }
}

#Create  autoscaling group sample for was server
resource "aws_autoscaling_group" "was_group" {
  name               = "was_asg_group"
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  target_group_arns    = var.was_target_group_arns
  vpc_zone_identifier  = var.was_private_subnet_id_list
  launch_template {
    id      = aws_launch_template.was_template.id
    version = "$Latest"
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "was-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create SecurityGroup for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Create SecurityGroup for Web Server
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [resource.aws_security_group.bastion_sg.id] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

#Create SecurityGroup for Was Server
resource "aws_security_group" "was_sg" {
  name        = "was_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.in_elb_sg_id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "was_sg"
  }
}
