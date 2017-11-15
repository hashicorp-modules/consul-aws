module "ssh_keypair_aws_override" {
  source = "../../../ssh-keypair-aws"
  # source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"

  name = "${var.name}-override"
}

module "consul_auto_join_instance_role" {
  source = "../../../consul-auto-join-instance-role-aws"
  # source = "git@github.com:hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  name = "${var.name}"
}

data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/../templates/bastion-init-systemd.sh.tpl")}"

  vars = {
    name = "${var.name}"
  }
}

module "network_aws" {
  source = "../../../network-aws"
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  release_version   = "${var.bastion_release_version}"
  consul_version    = "${var.bastion_consul_version}"
  vault_version     = "${var.bastion_vault_version}"
  nomad_version     = "${var.bastion_nomad_version}"
  os                = "${var.bastion_os}"
  os_version        = "${var.bastion_os_version}"
  bastion_count     = "${var.bastion_count}"
  instance_profile  = "${module.consul_auto_join_instance_role.instance_profile_id}" # Override instance_profile
  instance_type     = "${var.bastion_instance_type}"
  user_data         = "${data.template_file.bastion_user_data.rendered}" # Override user_data
  ssh_key_name      = "${module.ssh_keypair_aws_override.name}"
}

data "template_file" "consul_user_data" {
  template = "${file("${path.module}/../templates/consul-init-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    bootstrap_expect = "${length(module.network_aws.subnet_private_ids)}"
  }
}

module "consul_aws" {
  source = "../../../consul-aws"
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name             = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr_block}"
  subnet_ids       = "${module.network_aws.subnet_private_ids}"
  release_version  = "${var.consul_release_version}"
  consul_version   = "${var.consul_version}"
  os               = "${var.consul_os}"
  os_version       = "${var.consul_os_version}"
  count            = "${var.consul_count}"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}" # Override instance_profile
  instance_type    = "${var.consul_instance_type}"
  user_data        = "${data.template_file.consul_user_data.rendered}" # Custom user_data
  ssh_key_name     = "${module.network_aws.ssh_key_name}"
}
