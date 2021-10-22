
resource "aws_lb" "main" {
  count = var.alb_enable ? var.alb_count : 0
  # alb_enable         = var.alb_enable
  # no_attach          = true
  name               = "${var.app}-${var.stack}-alb"
  internal           = var.internal
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb.id]
  enable_http2       = var.enable_http2
  idle_timeout       = var.idle_timeout
  # listener_cert      = local.alb_cert_arn
  # health_matcher     = "200,301"
  # backend_protocol   = "HTTPS"
}

locals {
  listener_count  = length(var.listener_ports)
  backend_count  = length(var.backend_ports)

  targets = local.listener_count == 2 && local.backend_count ==1 ? concat(aws_lb_target_group.main.*.arn, aws_lb_target_group.main.*.arn) :aws_lb_target_group.main.*.arn
}

resource "aws_lb_listener" "main" {
  count = var.alb_enable ? var.alb_count : 0

  load_balancer_arn = join("", aws_lb.main.*.arn)
  certificate_arn   = var.listener_cert
  port = var.listener_ports[count.index]
  protocol = var.listener_protocol
  ssl_policy = var.ssl_policy

  default_action {
    target_group_arn    = element(local.targets, count.index)
    type                = forward
  }
}

resource "aws_lb_listener" "redirect_port_80" {
  count = var.alb_enable && var.redirect_port_80 != "" ? 1 : 0

  load_balancer_arn = join("", aws_lb.main[0].arn)
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect{
      port = var.redirect_port_80
      protocol = "HTTPS"
      status_code  = "HTTP_301"
    }
  }
}

# locals {
#   tg_port_digit_len = length(tostring(max(var.backend_ports...)))
#   tg_name_char_len  = length(substr(local.alb_name, 0, 32 - local.tg_port_digit_len - 4))
# }

resource "aws_lb_target_group" "main" {
  count = var.alb_enable ? length(var.backend_ports) : 0

  name     = "ckan-lb-tg"
  port     = var.backend_ports[count.index]
  protocol = var.backend_protocol
  vpc_id   = var.vpc_id

  health_check {
    protocol = var.backend_protocol
    path     = var.backend_health_check_paths[count.index]
    interval = var.health_interval
    timeout  = var.health_timeout
    matcher  = var.health_matcher
    healthy_threshold = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
  stickiness {
    type = var.stickiness_type
    cookie_duration = var.stickiness_cookie_duration
    enabled   = var.stickiness_enabled
  }
}

resource "aws_autoscaling_attachment" "main" {
  count = var.alb_enable && var.tg_attach && var.inst_count == 0 ? length(var.backend_ports) : 0

  autoscaling_group_name = var.asg_id
  alb_target_group_arn   = element(aws_lb_target_group.main.*.arn, count.index)
}

resource "aws_lb_target_group_attachment" "main" {
  count = var.alb_enable && var.tg_attach ? var.inst_count : 0

  target_group_arn = join("", aws_lb_target_group.main.*.arn)
  target_id        = element(var.inst_list, count.index)
}
