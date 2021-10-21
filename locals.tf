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

  ckan_domain   = local.map_ckan_domain[var.stack]
  admin_hst_role_name    = var.vpc == "pw2prd" || var.vpc == "pe1prd" ? data.aws_iam_role.admin_role[0].id : join("", aws_iam_role.*.name)
}
