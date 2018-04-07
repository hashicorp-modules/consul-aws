output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# Consul
# ------------------------------------------------------------------------------

You can now interact with Consul using any of the CLI
(https://www.consul.io/docs/commands/index.html) or
API (https://www.consul.io/api/index.html) commands.
${var.public ? format("\nView the Consul UI: %s\n\nThe Consul nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!\n", "${module.consul_lb_aws.consul_lb_dns}") : ""}
  # Use the CLI to retrieve the Consul members, write a key/value, and read that key/value
  $ consul members
  $ consul kv put cli bar=baz
  $ consul kv get cli

  # Use the API to retrieve the Consul members, write a key/value, and read that key/value
  $ curl \
    http://127.0.0.1:8500/v1/agent/members | jq '.'
  $ curl \
      -X PUT \
      -d '{"bar=baz"}' \
      http://127.0.0.1:8500/v1/kv/api | jq '.'
  $ curl \
      http://127.0.0.1:8500/v1/kv/api | jq '.'
README
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}

output "consul_lb_sg_id" {
  value = "${module.consul_lb_aws.consul_lb_sg_id}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_https_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_https_8500_arn}"
}

output "consul_lb_dns" {
  value = "${module.consul_lb_aws.consul_lb_dns}"
}

output "consul_asg_id" {
  value = "${element(concat(aws_autoscaling_group.consul.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_username" {
  value = "${lookup(var.users, var.os)}"
}
