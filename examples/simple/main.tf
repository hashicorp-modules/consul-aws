resource "random_id" "name" {
  byte_length = 4
  prefix      = "${var.environment}-"
}

module "ssh_keypair_aws" {
  # source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"
  source = "../../../ssh-keypair-aws"

  ssh_key_name = "${random_id.name.hex}"
}

module "network_aws" {
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"
  source = "../../../network-aws"

  environment  = "${var.environment}"
  ssh_key_name = "${module.ssh_keypair_aws.ssh_key_name}"
}

module "consul_aws" {
  # source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"
  source = "../../../consul-aws"

  environment  = "${var.environment}"
  vpc_id       = "${module.network_aws.vpc_id}"
  vpc_cidr     = "${module.network_aws.vpc_cidr_block}"
  subnet_ids   = "${module.network_aws.subnet_private_ids}"
  ssh_key_name = "${module.ssh_keypair_aws.ssh_key_name}"
}
