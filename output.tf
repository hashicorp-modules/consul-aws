output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# ${var.name} Consul
# ------------------------------------------------------------------------------

You can now interact with Consul using any of the CLI
(https://www.consul.io/docs/commands/index.html) or
API (https://www.consul.io/api/index.html) commands.

${format(
  "Consul UI: %s %s\n\n%s",
  module.consul_lb_aws.consul_lb_dns,
  var.public ? "(Public)" : "(Internal)",
  var.public ? "The Consul nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!" : "The Consul node(s) are in a private subnet, UI access can only be achieved inside\nthe network through a VPN.",
)}

Use the CLI to retrieve the Consul members, write a key/value, and read
that key/value.

  $ consul members # Retrieve Consul members
  $ consul kv put cli bar=baz # Write a key/value
  $ consul kv get cli # Read a key/value

Use the HTTP API to retrieve the Consul members, write a key/value,
and read that key/value.

${false == var.use_lb_cert ? "If you're making HTTP API requests to Consul from the Bastion host,\nthe below env var has been set for you.\n\n  $ export CONSUL_ADDR=http://127.0.0.1:8500\n\n  $ curl \\\n      -X GET \\\n      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members\n  $ curl \\\n      -X PUT \\\n      -d 'bar=baz' \\\n      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV\n  $ curl \\\n      -X GET \\\n      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV" : "If you're making HTTPS API requests to Consul from the Bastion host,\nthe below env vars have been set for you.\n\n  $ export CONSUL_ADDR=https://127.0.0.1:8080\n  $ export CONSUL_CACERT=/opt/consul/tls/consul-ca.crt\n  $ export CONSUL_CLIENT_CERT=/opt/consul/tls/consul.crt\n  $ export CONSUL_CLIENT_KEY=/opt/consul/tls/consul.key\n\n  $ curl \\\n      -X GET \\\n      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\\n      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members\n  $ curl \\\n      -X PUT \\\n      -d 'bar=baz' \\\n      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\\n      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV\n  $ curl \\\n      -X GET \\\n      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\\n      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV"}
README

}

output "consul_sg_id" {
  value = module.consul_server_sg.consul_server_sg_id
}

output "consul_lb_sg_id" {
  value = module.consul_lb_aws.consul_lb_sg_id
}

output "consul_tg_http_8500_arn" {
  value = module.consul_lb_aws.consul_tg_http_8500_arn
}

output "consul_tg_https_8080_arn" {
  value = module.consul_lb_aws.consul_tg_https_8080_arn
}

output "consul_lb_dns" {
  value = module.consul_lb_aws.consul_lb_dns
}

output "consul_asg_id" {
  value = element(concat(aws_autoscaling_group.consul.*.id, [""]), 0) # TODO: Workaround for issue #11210
}

output "consul_username" {
  value = var.users[var.os]
}

