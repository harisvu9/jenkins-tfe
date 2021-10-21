locals {
  map_ckan_domain = {
    "dev" = "hrb-dev"
    "qnt" = "hrb-qnt"
    "prd" = "hrb-prd"
  }

  ckan_domain   = local.map_ckan_domain[var.stack]
}
