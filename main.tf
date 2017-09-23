terraform {
  required_version = ">= 0.9.3"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "consul_server" {
  name               = "${var.environment}-Consul-Server"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

data "aws_iam_policy_document" "consul_server" {
  statement {
    sid       = "AllowSelfAssembly"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]
  }
}

resource "aws_iam_role_policy" "consul_server" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.consul_server.id}"
  policy = "${data.aws_iam_policy_document.consul_server.json}"
}

resource "aws_iam_instance_profile" "consul_server" {
  name = "${var.environment}-Consul-Server"
  role = "${aws_iam_role.consul_server.name}"
}

data "aws_ami" "consul" {
  most_recent = true
  owners      = ["362381645759"] # hc-se-demos Hashicorp Demos Account

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

data "template_file" "consul_init" {
  count    = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  template = "${file("${path.module}/templates/init-systemd.sh.tpl")}"

  vars = {
    hostname     = "${var.environment}-consul-${count.index}"
    environment  = "${var.environment}"
    consul_count = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  }
}

# TODO: Move the Consul AWS security groups into it's own module
# https://www.consul.io/docs/agent/options.html#ports
resource "aws_security_group" "consul_server" {
  name        = "consul-server-sg"
  description = "Security Group for Consul Server Instances"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name          = "Consul Server (${var.environment})"
    ConsulCluster = "${replace(var.environment, " ", "")}"
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Server RPC (Default 8300) - TCP. This is used by servers to handle incoming requests from other agents on TCP only.
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # Serf LAN (Default 8301) - TCP. This is used to handle gossip in the LAN. Required by all agents on TCP and UDP.
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # Serf LAN (Default 8301) - UDP. This is used to handle gossip in the LAN. Required by all agents on TCP and UDP.
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # As of Consul 0.8, it is recommended to enable connection between servers through port 8302 for both
  # TCP and UDP on the LAN interface as well for the WAN Join Flooding feature. See also: Consul 0.8.0
  # CHANGELOG and GH-3058
  # https://github.com/hashicorp/consul/blob/master/CHANGELOG.md#080-april-5-2017
  # https://github.com/hashicorp/consul/issues/3058

  # Serf WAN (Default 8302) - TCP. This is used by servers to gossip over the WAN to other servers on TCP and UDP.
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # Serf WAN (Default 8302) - UDP. This is used by servers to gossip over the WAN to other servers on TCP and UDP.
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # CLI RPC (Default 8400) - TCP. This is used by all agents to handle RPC from the CLI on TCP only.
  # This is deprecated in Consul 0.8 and later - all CLI commands were changed to use the
  # HTTP API and the RPC interface was completely removed.
  ingress {
    from_port   = 8400
    to_port     = 8400
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # HTTP API (Default 8500) - TCP. This is used by clients to talk to the HTTP API on TCP only.
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # DNS Interface (Default 8600) - TCP. Used to resolve DNS queries on TCP and UDP.
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # DNS Interface (Default 8600) - UDP. Used to resolve DNS queries on TCP and UDP.
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
    self        = true
  }

  # All outbound traffic - TCP.
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  # All outbound traffic - UDP.
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
}

resource "aws_launch_configuration" "consul_server" {
  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.consul_server.id}"
  image_id                    = "${data.aws_ami.consul.id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.consul_init.rendered}"
  key_name                    = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.consul_server.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul_server" {
  launch_configuration = "${aws_launch_configuration.consul_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.environment} Consul Servers"
  max_size             = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  min_size             = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  desired_capacity     = "${var.consul_count ? var.consul_count : length(var.subnet_ids)}"
  default_cooldown     = 30
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${format("%s Consul Server", var.environment)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment-Name"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
