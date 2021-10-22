data "aws_iam_role" "admin_role" {
  count = var.vpc == "pw2prd" || var.vpc == "pe1prd" ? 1 : 0
  name  = "admin-hst"
}

locals {
  _vpc = var.acct == "prod" ? "prd" : "dev"
  vpc  = var.vpc != "" ? var.vpc : var.map_west_vpc[local._vpc]

  map_ckan_domain = {
    "dev" = "hrb-dev"
    "qnt" = "hrb-qnt"
    "prd" = "hrb-prd"
  }

alb_certs_stack = {
  dev = "arn:aws:acm:us-west-2:432787484136:certificate/84ca4342-4c43-45c5-8ac0-7f4f7f65779e"
  qnt = "arn:aws:acm:us-west-2:432787484136:certificate/84ca4342-4c43-45c5-8ac0-7f4f7f65779e"
  prd = "arn:aws:acm:us-west-2:432787484136:certificate/84ca4342-4c43-45c5-8ac0-7f4f7f65779e"
}

alb_cert_arn = var.alb_cert_arn != "" ? var.alb_cert_arn : local.alb_certs_stack[var.stack]

ckan_domain   = local.map_ckan_domain[var.stack]

admin_hst_role_name    = var.vpc == "pw2prd" || var.vpc == "pe1prd" ? data.aws_iam_role.admin_role[0].id : join("", aws_iam_role.admin.*.name)

admin_hst_role_arn    = var.vpc == "pw2prd" || var.vpc == "pe1prd" ? data.aws_iam_role.admin_role[0].arn : join("", aws_iam_role.admin.*.arn)

}
