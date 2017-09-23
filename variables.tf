variable "environment" {
  description = "Environment name."
}

variable "release_version" {
  default     = "0.1.0-dev1"
  description = "Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1)"
}

variable "consul_version" {
  default     = "0.9.2"
  description = "Consul version tag (e.g. 0.9.2 or 0.9.2-ent)."
}

variable "os" {
  default     = "RHEL"
  description = "Operating System (e.g. RHEL or Ubuntu)."
}

variable "os_version" {
  default     = "7.3"
  description = "Operating System version (e.g. 7.3 for RHEL or 16.04 for Ubuntu)."
}

variable "vpc_id" {
  description = "VPC ID to provision resources in."
}

variable "vpc_cidr" {
  description = "VPC CIDR block to provision resources in."
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet ID(s) to provision resources in."
}

variable "ssh_key_name" {
  description = "AWS key name you will use to access the instance(s)."
}

variable "consul_count" {
  default     = "0"
  description = "Number of Consul nodes to provision across private subnets, defaults to private subnet count."
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type for Consul node (e.g. m4.large)."
}
