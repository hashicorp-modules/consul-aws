# AWS Consul Terraform Module

Creates a standard Consul cluster in AWS that includes:

- A Consul cluster with one node in each private subnet

This module requires a pre-existing AWS SSH key pair for each bastion host.

## Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `environment` - [Required] Environment name.
- `release_version` - [Optional] Release version tag to use (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1).
- `consul_version` - [Optional] Consul version tag to use (e.g. 0.9.2 or 0.9.2-ent).
- `os` - [Optional] Operating System to use (e.g. RHEL or Ubuntu).
- `os_version` - [Optional] Operating System version to use (e.g. 7.3 for RHEL or 16.04 for Ubuntu).
- `vpc_id` - [Optional] VPC ID to provision resources in.
- `vpc_cidr` - [Optional] VPC CIDR block to provision resources in.
- `subnet_ids` - [Optional] Subnet ID(s) to provision resources in.
- `ssh_key_name` - [Required] Name of AWS keypair that will be created.
- `consul_count` - [Optional] Number of Consul nodes to provision across private subnets, defaults to private subnet count.
- `instance_type` - [Optional] Instance type of the Consul node.

## Outputs

- `consul_asg_id` - Consul autoscaling group ID.
- `consul_sg_id` - Consul security group ID.

## Module Dependencies

- [AWS Network Terraform Module](https://github.com/hashicorp-modules/network-aws/)
- [AWS SSH Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-aws)
- [TLS Private Key Terraform Module](https://github.com/hashicorp-modules/tls-private-key)

## Image Dependencies

- [consul.json Packer template](https://github.com/hashicorp-modules/packer-templates/blob/master/consul/consul.json)

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
