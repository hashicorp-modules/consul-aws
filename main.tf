terraform {
  required_version = ">= 0.9.3"
}

module "consul_auto_join_instance_role" {
  source = "github.com/hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  create = "${var.create ? 1 : 0}"
  name   = "${var.name}"
}

data "aws_ami" "consul" {
  count       = "${var.create ? 1 : 0}"
  most_recent = true
  owners      = ["self"]
  name_regex  = "consul-image_${lower(var.release_version)}_consul_${lower(var.consul_version)}_${lower(var.os)}_${var.os_version}.*"

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
    values = ["${lower(var.release_version)}"]
  }

  filter {
    name   = "tag:Consul-Version"
    values = ["${lower(var.consul_version)}"]
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
  count    = "${var.create ? 1 : 0}"
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    name      = "${var.name}"
    count     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
    user_data = "${var.user_data != "" ? var.user_data : "echo 'No custom user_data'"}"
  }
}

module "consul_server_sg" {
  source = "github.com/hashicorp-modules/consul-server-ports-aws?ref=f-refactor"

  create      = "${var.create ? 1 : 0}"
  name        = "${var.name}-consul-server"
  vpc_id      = "${var.vpc_id}"
  cidr_blocks = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open Consul ports for public access - DO NOT DO THIS IN PROD
}

resource "aws_security_group_rule" "ssh" {
  count = "${var.create ? 1 : 0}"

  security_group_id = "${module.consul_server_sg.consul_server_sg_id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.public_ip != "false" ? "0.0.0.0/0" : var.vpc_cidr}"] # If there's a public IP, open port 22 for public access - DO NOT DO THIS IN PROD
}

resource "aws_launch_configuration" "consul" {
  count = "${var.create ? 1 : 0}"

  name_prefix                 = "${format("%s-consul-", var.name)}"
  associate_public_ip_address = "${var.public_ip != "false" ? true : false}"
  ebs_optimized               = false
  iam_instance_profile        = "${var.instance_profile != "" ? var.instance_profile : module.consul_auto_join_instance_role.instance_profile_id}"
  image_id                    = "${var.image_id != "" ? var.image_id : data.aws_ami.consul.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.consul_init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${module.consul_server_sg.consul_server_sg_id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul" {
  count = "${var.create ? 1 : 0}"

  name_prefix          = "${format("%s-consul-", var.name)}"
  launch_configuration = "${aws_launch_configuration.consul.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  max_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  min_size             = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  desired_capacity     = "${var.count != "-1" ? var.count : length(var.subnet_ids)}"
  default_cooldown     = 30
  force_delete         = true

  tags = ["${concat(
    list(
      map("key", "Name", "value", format("%s-consul-node", var.name), "propagate_at_launch", true),
      map("key", "Consul-Auto-Join", "value", var.name, "propagate_at_launch", true)
    ),
    var.tags
  )}"]
}
