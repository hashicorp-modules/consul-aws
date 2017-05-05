data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "consul_server" {
  statement {
    sid = "AllowSelfAssembly"
    effect = "Allow"
    resources = ["*"]
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]
  }
  statement {
    sid = "AllowConsulBackups"
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.consul_backup_bucket.arn}",
      "${aws_s3_bucket.consul_backup_bucket.arn}/*",
    ]
    actions = [
      "s3:*"
    ]
    lifecycle {
      prevent_destroy = true
    }
  }
}
