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


#Create Application Load Balancer for External
resource "aws_lb" "ex_alb" {
  name               = "ex-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ex_elb_sg.id]
  subnets            = tolist(var.public_subnet_id_list)

  enable_deletion_protection = false

  tags = {
    Environment = "ex_alb"
  }
}

#Create Application Load Balancer Target Group for External
resource "aws_lb_target_group" "ex_tg_80" {
  name     = "example-tg-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }
  stickiness {
    cookie_duration = "86400"
    type = "lb_cookie"
  }
  tags = {
    Environment = "ex_tg_80"
  }
}

# Create Application Load Balancer Listener for External
resource "aws_lb_listener" "ex_listener_80" {
  load_balancer_arn = resource.aws_lb.ex_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = resource.aws_lb_target_group.ex_tg_80.arn
  }
}

#Create Network Load Balancer  for internal
resource "aws_lb" "in_alb" {
  name               = "in-alb"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.in_elb_sg.id]
  subnets            = slice(var.private_subnet_id_list, 0, 2)

  enable_deletion_protection = false

  tags = {
    Environment = "in_alb"
  }
}

#Create Network Load Balancer Target Group for internal
resource "aws_lb_target_group" "in_tg_8080" {
  name     = "in-tg-8080"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id
  
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }

  stickiness {
    cookie_duration = "86400"
    type = "lb_cookie"
  }

  tags = {
    Environment = "in_tg_8080"
  }
}

# Create Network Load Balancer Listener for internal
resource "aws_lb_listener" "in_listener_8080" {
  load_balancer_arn = resource.aws_lb.in_alb.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = resource.aws_lb_target_group.in_tg_8080.arn
  }
}

#Create Security Group for External ALB
resource "aws_security_group" "ex_elb_sg" {
  name        = "ex_elb_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

#Create Security Group for Internal NLB
resource "aws_security_group" "in_elb_sg" {
  name        = "in_elb_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [var.web_sg_id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_sg"
  }
}
