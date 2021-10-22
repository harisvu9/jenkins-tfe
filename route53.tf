resource "aws_route53_zone" "ckan" {
  name = var.ckan_private_zone_domain

  vpc {
    vpc_id  = var.vpc_id
  }
}
