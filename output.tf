output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# ${var.name} Consul
# ------------------------------------------------------------------------------

You can now interact with Consul using any of the CLI
(https://www.consul.io/docs/commands/index.html) or
API (https://www.consul.io/api/index.html) commands.

${format("Consul UI: %s %s\n\n%s", module.consul_lb_aws.consul_app_lb_dns, !var.lb_internal ? "(Public)" : "(Internal)", !var.lb_internal ? "The Consul nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!" : "The Consul node(s) are in a private subnet, UI access can only be achieved inside\nthe network.")}

Use the CLI to retrieve the Consul members, write a key/value, and read
that key/value.

  $ consul members # Retrieve Consul members
  $ consul kv put cli bar=baz # Write a key/value
  $ consul kv get cli # Read a key/value

Use the HTTP API to retrieve the Consul members, write a key/value,
and read that key/value.

${!var.lb_use_cert ?
"If you're making HTTP API requests to Consul from the Bastion host,
the below env var has been set for you.

  $ export CONSUL_ADDR=http://127.0.0.1:8500

  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members
  $ curl \\
      -X PUT \\
      -d 'bar=baz' \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV
  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV"
:
"If you're making HTTPS API requests to Consul from the Bastion host,
the below env vars have been set for you.

  $ export CONSUL_ADDR=https://127.0.0.1:8080
  $ export CONSUL_CACERT=/opt/consul/tls/consul-ca.crt
  $ export CONSUL_CLIENT_CERT=/opt/consul/tls/consul.crt
  $ export CONSUL_CLIENT_KEY=/opt/consul/tls/consul.key

  $ curl \\
      -X GET \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members
  $ curl \\
      -X PUT \\
      -d 'bar=baz' \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV
  $ curl \\
      -X GET \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV"
}
README
}

output "consul_asg_id" {
  value = "${element(concat(aws_autoscaling_group.consul.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}

output "consul_app_lb_sg_id" {
  value = "${module.consul_lb_aws.consul_app_lb_sg_id}"
}

output "consul_lb_arn" {
  value = "${module.consul_lb_aws.consul_lb_arn}"
}

output "consul_app_lb_dns" {
  value = "${module.consul_lb_aws.consul_app_lb_dns}"
}

output "consul_network_lb_dns" {
  value = "${module.consul_lb_aws.consul_network_lb_dns}"
}

output "consul_tg_tcp_22_arn" {
  value = "${module.consul_lb_aws.consul_tg_tcp_22_arn}"
}

output "consul_tg_tcp_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_tcp_8500_arn}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_tcp_8080_arn" {
  value = "${module.consul_lb_aws.consul_tg_tcp_8080_arn}"
}

output "consul_tg_https_8080_arn" {
  value = "${module.consul_lb_aws.consul_tg_https_8080_arn}"
}

output "consul_tg_http_3030_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_3030_arn}"
}

output "consul_tg_https_3030_arn" {
  value = "${module.consul_lb_aws.consul_tg_https_3030_arn}"
}

output "consul_username" {
  value = "${lookup(var.users, var.os)}"
}
