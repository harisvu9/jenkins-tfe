# --------------------------------------
# ALB SG
# --------------------------------------
resource "aws_security_group" "alb" {
  name            = "ckan-alb"
  description     = "Allow inbound HTTPS traffic for ALBs which route to internal NGINX servers"
  vpc_id          = var.vpc_id

  dynamic "ingress"{
    for_each = var.ckan_services.https
    content {
      description = "https"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  dynamic "ingress"{
    for_each = var.ckan_services.https
    content {
      description = "https inbound from ${aws_security_group.loadbalancer.name} SG"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      security_groups = [aws_security_group.loadbalancer.id]
    }
  }

  dynamic "ingress"{
    for_each = var.ckan_services.http
    content {
      description = "http inbound from ${aws_security_group.loadbalancer.name} SG"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      security_groups = [aws_security_group.loadbalancer.id]
    }
  }

  egress {
    description = "alb outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Name          = "ckan-alb"
    BuiltBy       = "terraform"
    Owner         = "hari"
    Environment   = "sandbox"
    InfraLocation = "us-west-2"
  }

}

# --------------------------------------
# Admin SG
# --------------------------------------
resource "aws_security_group" "admin" {
  name            = "hst-admin"
  description     = "Allow inbound traffic from ckan admin hosts"
  vpc_id          = var.vpc_id
  tags = {
    Name          = "hst-admin"
    BuiltBy       = "terraform"
    Owner         = "hari"
    Environment   = "sandbox"
    InfraLocation = "us-west-2"
  }
}

locals {
  admin_services = concat(
  var.ckan_services.ckan_admin_services, var.ckan_services.ckan_docker_registry, var.ckan_services.ckan_docker_registry_int, var.ckan_services.beacon_prometheus
  )
}

resource "aws_security_group_rule" "admin_ingress" {
  count                     = length(local.admin_services)
  security_group_id         = aws_security_group.admin.id
  description               = "Allow inbound from admin host"
  type                      = "ingress"
  from_port                 = local.admin_services[count.index].from_port
  to_port                   = local.admin_services[count.index].to_port
  protocol                  = local.admin_services[count.index].protocol
  source_security_group_id  = aws_security_group.default-ssh.id
}

resource "aws_security_group_rule" "admin_egress" {
  security_group_id    = aws_security_group.admin.id
  description          = "Allow outbound from admin instance to hrb network"
  type                 = "egress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  cidr_blocks          = ["10.0.0.0/8"]
}

# --------------------------------------
# Default SSH SG
# --------------------------------------
resource "aws_security_group" "default-ssh" {
  name        = "default-ssh"
  description = "Allow inbound ssh traffic from bastions and priviliged internal servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow load balancers and admin hosts"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.admin.id]
  }

  egress {
    description = "Outbound to HRB network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "default-ssh"
    BuiltBy       = "terraform"
    Owner         = "hari"
    Environment   = "sandbox"
    InfraLocation = "us-west-2"
  }
}

# --------------------------------------
# Domain SG
# --------------------------------------
resource "aws_security_group" "domain" {
  name        = "hrb-qnt-dev"
  description = "Allow inbound from unpriviliged internal servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow B platform internal servers to communicate"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Outbound to HRB network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "default-ssh"
    BuiltBy       = "terraform"
    Owner         = "hari"
    Environment   = "sandbox"
    InfraLocation = "us-west-2"
  }
}
