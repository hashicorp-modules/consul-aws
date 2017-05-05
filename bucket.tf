resource "aws_s3_bucket" "consul_backup_bucket" {
  bucket = "consul_backup_bucket"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "Consul Backup Bucket"
  }
}
