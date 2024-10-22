variable "EC2_Instance_Type" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "Template_Instance_Type" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}



variable "public_subnet_count" {
  description = "Number of public subnets to create."
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets to create."
  type        = number
}

variable "main_vpc_id" {
  description = "Number of public subnets to create."
  type        = string
  default = ""
}

variable "public_subnet_id" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "private_subnet_id" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "bastion_host_sn" {
  description = "Number of public subnets to create."
  type        = string
  default = null
}



variable "web_private_subnet_id_list" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "was_private_subnet_id_list" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "was_target_group_arns" {
  description = "Number of public subnets to create."
  type        = set(string)
  default= null
}

variable "web_target_group_arns" {
  description = "Number of public subnets to create."
  type        = set(string)
  default= null
}

variable "ex_elb_sg" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "in_elb_sg" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "web_template_pri_subnet_id" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "was_template_pri_subnet_id" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}