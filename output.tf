output "consul_asg_id" {
  value = "${aws_autoscaling_group.consul_server.id}"
}

output "consul_sg_id" {
  value = "${aws_security_group.consul_server.id}"
}
