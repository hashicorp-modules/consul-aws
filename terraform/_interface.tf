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

variable "OS" {
  default = "RHEL"
  description = "Operating System to use. So far only RHEL supported. Ubuntu will be supported soon"
}

variable "OS-Version" {
  default = "7.3"
  description = "Operating System Version. I.E. 7.3 for RHEL or 14.04 for Ubuntu."
}

variable "Consul-Version" {
  default = "0.7.5"
  description = "Vault Product Version"
}

variable "region" {
  default = "us-west-1"
  description = "Region where this consul cluster will live. Used to find out Cluster members"
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

