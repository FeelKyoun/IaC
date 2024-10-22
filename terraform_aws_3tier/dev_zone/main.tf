
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

#Sample of creating a resource by calling a submodule from the root module
module "EC2" {
source = "../modules/computer/EC2"
bastion_host_sn = module.vpc.bastion_host_sn_id
in_elb_sg_id = module.elb.in_elb_sg_id
EC2_Instance_Type = "t2.micro"
Template_Instance_Type = "t2.micro"
main_vpc_id = module.vpc.main_vpc_id
was_target_group_arns = [module.elb.in_tg_8080_arn]
web_target_group_arns = [module.elb.ex_tg_80_arn]
was_private_subnet_id_list = [element(module.vpc.private_subnet_id_list,2),element(module.vpc.private_subnet_id_list,3)]
web_private_subnet_id_list = [element(module.vpc.private_subnet_id_list,0),element(module.vpc.private_subnet_id_list,1)]
web_template_pri_subnet_id = element(module.vpc.private_subnet_id_list,0)
was_template_pri_subnet_id = element(module.vpc.private_subnet_id_list,2)
}

module "RDS" {
source = "../modules/computer/RDS"
RDS_Instance_Class = "db.t3.micro"
private_subnet_id = tolist(module.vpc.private_subnet_id_list)
was_sg_id = module.EC2.was_sg_id
main_vpc_id = module.vpc.main_vpc_id
}

module "s3" {
source = "../modules/computer/S3"
}

module "vpc" {
source = "../modules/network/VPC"
public_subnet_count  = var.public_subnet_count
private_subnet_count = var.private_subnet_count
}


module "elb" {
source = "../modules/network/ELB"
main_vpc_id = module.vpc.main_vpc_id
public_subnet_id_list = module.vpc.public_subnet_id_list
private_subnet_id_list = module.vpc.private_subnet_id_list
web_sg_id = module.EC2.web_sg_id
}