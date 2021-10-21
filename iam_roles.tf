# -----------------------------------------------
# admin-role
# -----------------------------------------------

resource "aws_iam_role" "admin" {
  name            = "admin-hst"
  description = "CKAN admin role for VMs which need to manage compute resources"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  force_detach_policies = true
  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "admin" {
  name = "admin-hst"
  # role = local.admin_wst_role_name
  role = aws_iam_role.admin.name
}

resource "aws_iam_policy" "admin" {
  name = "prod-ckan-prd-admin-hst"
  description = "CKAN admin policy"
  policy = data.aws_iam_policy_document.ckan_admin.json
}

resource "aws_iam_role_policy_attachment" "admin" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.admin.name
  policy_arn = aws_iam_policy.admin.arn
}

resource "aws_iam_role_policy_attachment" "admin_ssm" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::432787484136:policy/prod-ssm-agent-policy"
}

# -----------------------------------------------
# compute-role
# -----------------------------------------------

resource "aws_iam_role" "compute" {
  name            = "default-hrb-${var.stack}"
  description = "CKAN unprivileged role for compute and data VMs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  force_detach_policies = true
  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "compute" {
  name = "default-${var.ckan_domain}"
  # role = local.admin_wst_role_name
  role = aws_iam_role.compute.name
}

resource "aws_iam_role_policy_attachment" "compute_ssm" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.compute.name
  policy_arn = "arn:aws:iam::432787484136:policy/prod-ssm-agent-policy"
}

resource "aws_iam_policy" "ec2" {
  name = "prod-ckan-prd-ec2-hst"
  description = "CKAN EC2 instance policy"
  policy = data.aws_iam_policy_document.ckan_ec2.json
}

resource "aws_iam_policy" "volumes" {
  name = "prod-ckan-prd-volumes-hst"
  description = "CKAN EBS volume policy"
  policy = data.aws_iam_policy_document.volumes.json
}

resource "aws_iam_policy" "s3_access" {
  name = "prod-ckan-prd-s3-access-hst"
  description = "CKAN S3 access policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "compute_ec2" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.compute.name
  policy_arn = aws_iam_policy.ec2.arn
}

resource "aws_iam_role_policy_attachment" "compute_volumes" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.compute.name
  policy_arn = aws_iam_policy.volumes.arn
}

resource "aws_iam_role_policy_attachment" "compute_s3_access" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.compute.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# -----------------------------------------------
# vault-role
# -----------------------------------------------

resource "aws_iam_role" "vault" {
  name            = "vault-frb-${var.stack}"
  description = "CKAN vault server role which allows access to an unseal"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault-${var.ckan_domain}"
  # role = local.admin_wst_role_name
  role = aws_iam_role.vault.name
}

resource "aws_iam_role_policy_attachment" "vault_ssm" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::432787484136:policy/prod-ssm-agent-policy"
}

resource "aws_iam_role_policy_attachment" "vault_ec2" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.ec2.arn
}

resource "aws_iam_role_policy_attachment" "vault_volumes" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.volumes.arn
}

resource "aws_iam_role_policy_attachment" "vault_s3_access" {
  # role = local.admin_wst_role_name
  role = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# -----------------------------------------------
# Replication role
# -----------------------------------------------

resource "aws_iam_role" "replication" {
  count = var.create_source_repl_resources ? 1 : 0

  name            = "prd-ckan-replication-role"
  description = "Role for S3 replication of ckan installation configs and files"
  assume_role_policy = data.aws_iam_policy_document.assume_role_s3.json
}
