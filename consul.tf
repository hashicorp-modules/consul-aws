terraform {
  required_version = ">= 0.9.3"
}

data "aws_ami" "consul" {
  most_recent = true
  owners      = ["362381645759"] # hc-se-demos Hashicorp Demos New Account

  filter {
    name   = "tag:System"
    values = ["Consul"]
  }

  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }

  filter {
    name   = "tag:Product-Version"
    values = ["${var.consul_version}"]
  }

  filter {
    name   = "tag:OS"
    values = ["${var.os}"]
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

resource "aws_iam_role" "consul_server" {
  name               = "${var.cluster_name}-Consul-Server"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "consul_server" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.consul_server.id}"
  policy = "${data.aws_iam_policy_document.consul_server.json}"
}

resource "aws_iam_instance_profile" "consul_server" {
  name = "${var.cluster_name}-Consul-Server"
  role = "${aws_iam_role.consul_server.name}"
}

data "template_file" "init" {
  template = "${file("${path.module}/init-cluster.tpl")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    environment_name = "${var.environment_name}"
  }
}

resource "aws_launch_configuration" "consul_server" {
  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.consul_server.id}"
  image_id                    = "${data.aws_ami.consul.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.consul_server.id}",
    "${aws_security_group.consul_client.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul_server" {
  launch_configuration = "${aws_launch_configuration.consul_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.cluster_name} Consul Servers"
  max_size             = "${var.cluster_size}"
  min_size             = "${var.cluster_size}"
  desired_capacity     = "${var.cluster_size}"
  default_cooldown     = 30
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${format("%s Consul Server", var.cluster_name)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster-Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment-Name"
    value               = "${var.environment_name}"
    propagate_at_launch = true
  }
}
