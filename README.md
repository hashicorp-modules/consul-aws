# AWS Consul Terraform Module

Creates a standard Consul cluster in AWS that includes:

- A Consul cluster with one node in each private subnet

## Requirements

This module requires a pre-existing AWS key pair, VPC, and subnet be available to deploy the auto-scaling group within. See [Recommended Modules](#recommended-modules) to easily provision these resources and populate required variables.

Checkout [examples](./examples) for fully functioning examples.

## Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `create`: [Optional] Create Module, defaults to true.
- `name`: [Optional] Name for resources, defaults to "consul-aws".
- `release_version`: [Optional] Release version tag to use (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to "0.1.0-dev1".
- `consul_version`: [Optional] Consul version tag to use (e.g. 1.0.6 or 1.0.6-ent), defaults to "1.0.6".
- `os`: [Optional] Operating System to use (e.g. RHEL or Ubuntu), defaults to "RHEL".
- `os_version`: [Optional] Operating System version to use (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to "7.3".
- `vpc_id`: [Required] VPC ID to provision resources in.
- `vpc_cidr`: [Optional] VPC CIDR block to provision resources in.
- `subnet_ids`: [Optional] Subnet ID(s) to provision resources in.
- `public`: [Optional] Open up nodes to the public internet for easy access - DO NOT DO THIS IN PROD, defaults to false.
- `count`: [Optional] Number of Consul nodes to provision across private subnets, defaults to private subnet count.
- `instance_type`: [Optional] AWS instance type for Consul node (e.g. "m4.large"), defaults to "t2.small".
- `image_id`: [Optional] AMI to use, defaults to the HashiStack AMI.
- `instance_profile`: [Optional] AWS instance profile to use, defaults to consul-auto-join-instance-role module.
- `user_data`: [Optional] user_data script to pass in at runtime.
- `ssh_key_name`: [Required] Name of AWS keypair that will be created.
- `use_lb_cert`: [Optional] Use certificate passed in for the LB IAM listener, "lb_cert" and "lb_private_key" must be passed in if true, defaults to false.
- `lb_cert`: [Optional] Certificate for LB IAM server certificate.
- `lb_private_key`: [Optional] Private key for LB IAM server certificate.
- `lb_cert_chain`: [Optional] Certificate chain for LB IAM server certificate.
- `lb_ssl_policy`: [Optional] SSL policy for LB, defaults to "ELBSecurityPolicy-2016-08".
- `lb_bucket`: [Optional] S3 bucket override for LB access logs, `lb_bucket_override` be set to true if overriding.
- `lb_bucket_override`: [Optional] Override the default S3 bucket created for access logs, defaults to false, `lb_bucket` _must_ be set if true.
- `lb_bucket_prefix`: [Optional] S3 bucket prefix for LB access logs.
- `lb_logs_enabled`: [Optional] S3 bucket LB access logs enabled, defaults to true.
- `target_groups`: [Optional] List of target group ARNs to apply to the autoscaling group.
- `users`: [Optional] Map of SSH users.
- `tags`: [Optional] Optional list of tag maps to set on resources, defaults to empty list.
- `tags_list`: [Optional] Optional map of tags to set on resources, defaults to empty map.

## Outputs

- `zREADME`: README for module.
- `consul_sg_id`: Consul security group ID.
- `consul_lb_sg_id`: Consul load balancer security group ID.
- `consul_tg_http_8500_arn`: Consul load balancer HTTP 8500 target group.
- `consul_tg_https_8080_arn`: Consul load balancer HTTPS 8080 target group.
- `consul_lb_dns`: Consul load balancer DNS name.
- `consul_asg_id`: Consul autoscaling group ID.
- `consul_username`: The Consul host username.

## Submodules

- [AWS Consul Auto Join Instance Role Terraform Module](https://github.com/hashicorp-modules/consul-auto-join-instance-role)
- [AWS Consul Server Ports Terraform Module](https://github.com/hashicorp-modules/consul-server-ports-aws)

## Recommended Modules

These are recommended modules you can use to populate required input variables for this module. The sub-bullets show the mapping of output variable --> required input variable for the respective modules.

- [AWS SSH Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-aws)
  - `ssh_key_name` --> `ssh_key_name`
- [AWS Network Terraform Module](https://github.com/hashicorp-modules/network-aws/)
  - `vpc_cidr` --> `vpc_cidr`
  - `vpc_id` --> `vpc_id`
  - `subnet_private_ids` --> `subnet_ids`

## Image Dependencies

- [consul.json Packer template](https://github.com/hashicorp/guides-configuration/blob/master/consul/consul.json)

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
