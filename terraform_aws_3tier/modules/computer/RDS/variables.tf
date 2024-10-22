variable "private_subnet_id" {
  description = "Number of public subnets to create."
  type        = list
  default= null
}

variable "RDS_Instance_Class" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "was_sg_id" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}

variable "main_vpc_id" {
  description = "Number of public subnets to create."
  type        = string
  default= null
}