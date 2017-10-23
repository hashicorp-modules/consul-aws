output "consul_asg_id" {
  value = "${aws_autoscaling_group.consul_server.id}"
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}
