# consul-aws

Provisions resources for a Consul auto-scaling group in AWS.

## Requirements

This module requires a pre-existing AWS key pair, VPC and subnet be available to
deploy the auto-scaling group within. It's recommended you combine this module
with [network-aws](https://github.com/hashicorp-modules/network-aws/) which
provisions a VPC and a private and public subnet per AZ. See the usage section
for further guidance.

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Terraform Variables

You can pass the following Terraform variables during `terraform apply` or
in a `terraform.tfvars` file. Examples below:

- `cluster_name` = "consul-test"
- `os` = "RHEL"
- `os_version` = "7.3"
- `ssh_key_name` = "test_aws"
- `subnet_ids` = ["subnet-57392f0f"]
- `vpc_id` = "vpc-7b28a11f"

## Outputs

- `asg_id`
- `consul_client_sg_id`
- `consul_server_sg_id`
- `consul_backup_bucket`

## Images

- [consul-server.json Packer template](https://github.com/hashicorp-modules/packer-templates/blob/master/consul/consul-server.json)

## Usage

When combined with [network-aws](https://github.com/hashicorp-modules/network-aws/)
the `vpc_id` and `subnet_ids` variables are output from that module so you should
not supply them. Replace the `cluster_name` variable with `environment_name`.

```
variable "environment_name" {
  default = "consul-test"
  description = "Environment Name"
}

variable "os" {
  # case sensitive for AMI lookup
  default = "RHEL"
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  default = "7.3"
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

variable "ssh_key_name" {
  default = "test_aws"
  description = "Pre-existing AWS key name you will use to access the instance(s)"
}

module "network-aws" {
  source           = "git@github.com:hashicorp-modules/network-aws.git?ref=dan-refactor"
  environment_name = "${var.environment_name}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_key_name     = "${var.ssh_key_name}"
}

module "consul-aws" {
  source       = "git@github.com:hashicorp-modules/consul-aws.git?ref=dan-refactor"
  cluster_name = "${var.environment_name}-consul-asg"
  os           = "${var.os}"
  os_version   = "${var.os_version}"
  ssh_key_name = "${var.ssh_key_name}"
  subnet_ids   = "${module.network-aws.subnet_private_ids}"
  vpc_id       = "${module.network-aws.vpc_id}"
}
```
