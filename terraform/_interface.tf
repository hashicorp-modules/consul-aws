##
# INPUTS
##
variable "vpc_id" {
	type = "string"
}

variable "subnets" {
	type = "list"
}

variable "cluster_size" {
	default = "3"
}

variable "cluster_name" {
	default = "consul"
}

variable "ami" {
	type = "string"
}

variable "instance_type" {
	default = "m4.large"
}

##
# OUTPUTS
##
output "asg_id" {
	value = "${aws_autoscaling_group.consul_server.id}"
}

output "consul_server_sg" {
	value = "${aws_security_group.consul_server.id}"
}

output "consul_client_sg" {
	value = "${aws_security_group.consul_client.id}"
}

