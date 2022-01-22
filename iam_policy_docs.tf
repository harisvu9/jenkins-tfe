data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_s3" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ckan_admin" {
  statement {
    sid     = "AllowS3"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::hrb-pw2-ckan/*",
      "arn:aws:s3:::hrb-pw2-ckan"
    ]

  }
  statement {
      sid     = "AllowKmsListAliasandEc2"
      effect  = "Allow"
      actions = [
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:RunInstances",
          "ec2:CancelSpotRequest",
          "ec2:RequestSpotInstances",
          "kms:ListAliases",
          "ec2:Describe*",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:ModifyInstanceCreditSpecification",
          # "ec2:CreateLaunchTemplateVersion",
          # "ec2:ModifyLaunchTemplate",
          # "autoscaling:DescribeAutoScalingGroups",
          # "autoscaling:CreateAutoScalingGroup",
          # "autoscaling:AttachInstances",
          # "autoscaling:UpdateAutoScalingGroup",
          # "iam:CreateServiceLinkedRole"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "CreateEc2Tags"
      effect  = "Allow"
      actions = [
          "ec2:CreateTags"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "Ec2InstanceAccess"
      effect  = "Allow"
      actions = [
          "ec2:DeleteSnapshot",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:ModifyInstanceAttribute"
      ]
      resources = ["*"]
      condition {
        test = "StringEquals"
        variable = "ec2:ResourceTag/hst_domain"
        values = ["${local.ckan_domain}"]
      }
  }

  statement {
      sid         = "ELBFullAccess"
      effect      = "Allow"
      actions     = ["elasticloadbalancing:*"]
      resources   = ["*"]
      condition {
        test      = "StringEquals"
        variable  = "ec2:ResourceTag/hst_domain"
        values    = ["${local.ckan_domain}"]
      }
  }

  statement {
      sid     = "IamAccess"
      effect  = "Allow"
      actions = [
          "iam:ListRoles",
          "iam:PassRole"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "Route53RecordSets"
      effect  = "Allow"
      actions = [
          "route53:ChangeResourceRecordSets"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "ListRoute53HostedZones"
      effect  = "Allow"
      actions = [
          "route53:ListHostedZones"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "AllowENICreateAttach"
      effect  = "Allow"
      actions = [
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "AllowASGActions"
      effect  = "Allow"
      actions = [
          "ec2:DescribeTargetGroups",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:AttachInstances",
          "autoscaling:UpdateAutoScalingGroup",
          "iam:CreateServiceLinkedRole"
          # "ec2:CreateLaunchTemplateVersion",
          # "ec2:ModifyLaunchTemplate",
          # "autoscaling:DescribeAutoScalingGroups",
          # "autoscaling:CreateAutoScalingGroup",
          # "autoscaling:AttachInstances",
          # "autoscaling:UpdateAutoScalingGroup",
          # "iam:CreateServiceLinkedRole"
      ]
      resources = ["*"]
  }

}

data "aws_iam_policy_document" "ckan_ec2" {
  statement {
      sid     = "AllowEC2andKMSAlias"
      effect  = "Allow"
      actions = [
          "ec2:Describe*",
          "ec2:RunInstances",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "kms:ListAliases"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "AllowCloudWatchMonitoring"
      effect  = "Allow"
      actions = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "cloudwatch:PutMetricData"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "SNSPublish"
      effect  = "Allow"
      actions = ["sns:Publish"]
      resources = ["*"]
  }
  statement {
      sid     = "AllowCloudWatchLogging"
      effect  = "Allow"
      actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
      ]
      resources = ["*"]
  }
  statement {
      sid     = "S3List"
      effect  = "Allow"
      actions = ["s3:ListBucket"]
      resources = [for bucket in var.ckan_release_buckets : format("arn:aws:s3:::%s", bucket)]
      condition {
        test   = "StringLike"
        variable = "s3:prefix"
        values   = ["build/*"]
      }
  }
  statement {
      sid     = "ReleaseBucketGetList"
      effect  = "Allow"
      actions = ["s3:Get*", "s3:List*"]
      resources = [for bucket in var.ckan_release_buckets : format("arn:aws:s3:::%s/build/*", bucket)]
  }
  statement {
      sid     = "VaultIAMandKMSAlias"
      effect  = "Allow"
      actions = [
          "iam:GetInstanceProfile",
          "iam:GetUser",
          "iam:GetRole",
          "kms:ListAliases"
      ]
      resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid       = "S3ListandLocation"
    effect    = "Allow"
    actions   = ["s3:List*", "s3:GetBucketLocation"]
    resources = ["*"]
  }
  statement {
    sid       = "S3AccessSubfolders"
    effect    = "Allow"
    actions   = ["s3:Get*", "s3:List*", "s3:Put*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "volumes" {
  statement {
    effect    = "Allow"
    actions = [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "ec2:ResourceTag/hst_domain"
      values = ["${local.ckan_domain}"]
    }
  }
}
