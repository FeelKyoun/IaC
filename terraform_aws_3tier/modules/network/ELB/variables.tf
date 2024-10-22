variable "main_vpc_id" {
  description = "Number of public subnets to create."
  type        = string
}

variable "public_subnet_id_list" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "private_subnet_id_list" {
  description = "Number of public subnets to create."
  type        = list
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

variable "web_sg_id" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}