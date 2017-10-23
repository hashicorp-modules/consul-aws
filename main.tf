terraform {
  required_version = ">= 0.9.3"
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
    name         = "${var.name}"
    consul_count = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  }
}

module "consul_server_sg" {
  source = "../consul-server-ports-aws"
  # source = "git@github.com:hashicorp-modules/consul-server-ports-aws?ref=f-refactor"

  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  cidr_blocks = ["${var.vpc_cidr}"]
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${module.consul_server_sg.consul_server_sg_id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.vpc_cidr}"]
}

resource "aws_launch_configuration" "consul_server" {
  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${var.instance_profile}"
  image_id                    = "${data.aws_ami.consul.id}"
  instance_type               = "${var.consul_instance}"
  user_data                   = "${data.template_file.consul_init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${module.consul_server_sg.consul_server_sg_id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul_server" {
  launch_configuration = "${aws_launch_configuration.consul_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.name}-consul-servers"
  max_size             = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  min_size             = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  desired_capacity     = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
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
}
