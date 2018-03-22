output "consul_asg_id" {
  value = "${element(concat(aws_autoscaling_group.consul.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}

output "consul_username" {
  value = "${lookup(var.users, var.os)}"
}
