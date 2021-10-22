resource "aws_lb" "main" {
  alb_enable         = var.alb_enable
  no_attach          = true
  name               = "${var.app}-${var.stack}"
  vpc_id             = var.vpc_id
  security_groups    = [aws_security_group.alb.id]
  listener_cert      = local.alb_cert_arn
  # health_matcher     = "200,301"
  backend_protocol   = "HTTPS"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = join("", aws_lb.main.*.arn)
  certificate_arn   = var.listener_cert
}

# resource "aws_lb_target_group" "main" {
#   name     = "ckan-lb-tg"
#   port     = 443
#   protocol = "HTTPS"
#   target_type = "instance"
#   vpc_id   = var.vpc_id
# }

# resource "aws_lb_target_group_attachment" "main" {
#   # count = var.alb_enable && var.tg_attach ? var.inst_count : 0
#
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = element(var.inst_list, count.index)
# }
