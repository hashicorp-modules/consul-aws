resource "random_id" "name" {
  byte_length = 4
  prefix      = "${var.name}-"
}

module "ssh_keypair_aws" {
  source = "../../../ssh-keypair-aws"
  # source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"

  ssh_key_name = "${random_id.name.hex}"
}

module "consul_auto_join_instance_role" {
  source = "../../../consul-auto-join-instance-role-aws"
  # source = "git@github.com:hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  name = "${var.name}"
}

module "network_aws" {
  source = "../../../network-aws"
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name             = "${var.name}"
  bastion_connect  = "true"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}"
  ssh_key_name     = "${module.ssh_keypair_aws.ssh_key_name}"
}

module "consul_aws" {
  source = "../../../consul-aws"
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name             = "${var.name}"
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr_block}"
  subnet_ids       = "${module.network_aws.subnet_private_ids}"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}"
  ssh_key_name     = "${module.ssh_keypair_aws.ssh_key_name}"
}
