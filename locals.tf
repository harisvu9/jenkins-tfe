locals {
  map_ckan_domain = {
    "dev" = "hrb-dev"
    "qnt" = "hrb-qnt"
    "prd" = "hrb-prd"
  }

  ckan_domain   = local.map_ckan_domain[var.stack]
  admin_hst_role_name    = var.vpc == "pw2prd" || var.vpc == "pe1prd" ? data.aws_iam_role.admin_role[0].id : join("", aws_iam_role.*.name)
}
