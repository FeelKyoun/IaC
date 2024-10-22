output "main_vpc_id" {
  value = resource.aws_vpc.main_vpc.id
}

output "bastion_host_sn_id" {

  value = resource.aws_subnet.public_subnet[0].id

}


output "public_subnet_id_list" {
  value = resource.aws_subnet.public_subnet[*].id
}

output "private_subnet_id_list" {
  value = resource.aws_subnet.private_subnet[*].id
}