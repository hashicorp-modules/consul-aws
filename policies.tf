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
#	statement {
#		sid = "AllowConsulBackups"
#		effect = "Allow"
#		resources = [
#			"${var.backup_bucket_arn}",
#			"${var.backup_bucket_arn}/*",
#		]
#		actions = [
#			"s3:*"
#		]
#	}
}
