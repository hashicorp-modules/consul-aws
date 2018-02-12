output "consul_asg_id" {
  value = "${aws_autoscaling_group.consul.id}"
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}

output "consul_username" {
  value = "${lookup(var.users, var.os)}"
}
