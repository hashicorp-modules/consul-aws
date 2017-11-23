# AWS Consul Terraform Module

Creates a standard Consul cluster in AWS that includes:

- A Consul cluster with one node in each private subnet

## Requirements

This module requires a pre-existing AWS key pair, VPC, and subnet be available to deploy the auto-scaling group within. See [Recommended Modules](#recommended-modules) to easily provision these resources and populate required variables.

Consider using [hashicorp-guides/consul](https://github.com/hashicorp-guides/consul/blob/master/terraform-aws/) or checkout [examples](./examples) for fully functioning examples.

## Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `name`: [Optional] Name for resources, defaults to "consul-aws".
- `release_version`: [Optional] Release version tag to use (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to "0.1.0-dev1".
- `consul_version`: [Optional] Consul version tag to use (e.g. 0.9.2 or 0.9.2-ent), defaults to "0.9.2".
- `os`: [Optional] Operating System to use (e.g. RHEL or Ubuntu), defaults to "RHEL".
- `os_version`: [Optional] Operating System version to use (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to "7.3".
- `vpc_id`: [Required] VPC ID to provision resources in.
- `vpc_cidr`: [Optional] VPC CIDR block to provision resources in.
- `subnet_ids`: [Optional] Subnet ID(s) to provision resources in.
- `count`: [Optional] Number of Consul nodes to provision across private subnets, defaults to private subnet count.
- `public_ip`: [Optional] Associate a public IP address to the Consul nodes, defaults to "false".
- `image_id`: [Optional] AMI to use, defaults to the HashiStack AMI.
- `instance_profile`: [Optional] AWS instance profile to use, defaults to consul-auto-join-instance-role module.
- `instance_type`: [Optional] AWS instance type for Consul node (e.g. "m4.large"), defaults to "t2.small".
- `user_data`: [Optional] user_data script to pass in at runtime.
- `ssh_key_name`: [Required] Name of AWS keypair that will be created.
- `user`: [Optional] Map of SSH users.

## Outputs

- `consul_asg_id`: Consul autoscaling group ID.
- `consul_sg_id`: Consul security group ID.
- `consul_username`: The Consul host username.

## Submodules

- [AWS Consul Auto Join Instance Role Terraform Module](https://github.com/hashicorp-modules/consul-auto-join-instance-role)
- [AWS Consul Server Ports Terraform Module](https://github.com/hashicorp-modules/consul-server-ports-aws)

## Recommended Modules

These are recommended modules you can use to populate required input variables for this module. The sub-bullets show the mapping of output variable --> required input variable for the respective modules.

- [AWS SSH Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-aws)
  - `ssh_key_name` --> `ssh_key_name`
- [AWS Network Terraform Module](https://github.com/hashicorp-modules/network-aws/)
  - `vpc_cidr_block` --> `vpc_cidr`
  - `vpc_id` --> `vpc_id`
  - `subnet_private_ids` --> `subnet_ids`

## Image Dependencies

- [consul.json Packer template](https://github.com/hashicorp/guides-configuration/blob/master/consul/consul.json)

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
