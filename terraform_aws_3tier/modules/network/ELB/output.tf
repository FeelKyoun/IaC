/*output "target_group_arn_list" {
  value = [
    resource.aws_lb_target_group.ex_tg_80.arn,
    resource.aws_lb_target_group.in_tg_8080.arn
  ]
}*/


output "ex_tg_80_arn" {
  value = aws_lb_target_group.ex_tg_80.arn
}

output "in_tg_8080_arn" {
  value = aws_lb_target_group.in_tg_8080.arn
}

output "in_elb_sg_id" {
  value = aws_security_group.in_elb_sg.id
}