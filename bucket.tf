resource "aws_s3_bucket" "consul_backup_bucket" {
  bucket = "consul-backup-bucket-${var.cluster_name}"
  acl    = "private"
  lifecycle {
    prevent_destroy = true
  }
  tags {
    Name        = "Consul Backup Bucket"
  }
}
