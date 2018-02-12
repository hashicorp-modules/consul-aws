terraform {
  required_version = ">= 0.9.3"
}

module "consul_auto_join_instance_role" {
  source = "git@github.com:hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  name = "${var.name}"
}

data "aws_ami" "consul" {
  most_recent = true
  owners      = ["362381645759"] # hc-se-demos Hashicorp Demos Account

  filter {
    name   = "tag:System"
    values = ["Consul"]
  }

  filter {
    name   = "tag:Product"
    values = ["Consul"]
  }

  filter {
    name   = "tag:Release-Version"
    values = ["${var.release_version}"]
  }

  filter {
    name   = "tag:Consul-Version"
    values = ["${var.consul_version}"]
  }

  filter {
    name   = "tag:OS"
    values = ["${lower(var.os)}"]
  }

  filter {
    name   = "tag:OS-Version"
    values = ["${var.os_version}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "consul_init" {
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    name      = "${var.name}"
    count     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
    user_data = "${var.user_data != "" ? var.user_data : "echo 'No custom user_data'"}"
  }
}

module "consul_server_sg" {
  source = "git@github.com:hashicorp-modules/consul-server-ports-aws?ref=f-refactor"

  name        = "${var.name}-consul-server"
  vpc_id      = "${var.vpc_id}"
  cidr_blocks = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open Consul ports for public access - DO NOT DO THIS IN PROD
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${element(module.consul_server_sg.consul_server_sg_id, 0)}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open port 22 for public access - DO NOT DO THIS IN PROD
}

resource "aws_launch_configuration" "consul_server" {
  associate_public_ip_address = "${var.public_ip != "false" ? true : false}"
  ebs_optimized               = false
  iam_instance_profile        = "${var.instance_profile != "" ? var.instance_profile : element(module.consul_auto_join_instance_role.instance_profile_id, 0)}"
  image_id                    = "${var.image_id != "" ? var.image_id : data.aws_ami.consul.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.consul_init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${element(module.consul_server_sg.consul_server_sg_id, 0)}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul_server" {
  launch_configuration = "${aws_launch_configuration.consul_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.name}-consul-servers"
  max_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  min_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  desired_capacity     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  default_cooldown     = 30
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${format("%s-consul-server", var.name)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Consul-Auto-Join"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }

  tag {
    key                 = "TTL"
    value               = "${var.ttl}"
    propagate_at_launch = true
  }
}
