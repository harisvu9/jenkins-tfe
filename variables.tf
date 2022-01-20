provider "aws" {
  region     = "${var.region}"
}

variable "region" {
  default = "us-west-2"
}
variable "vpc_id" {
  default = "vpc-807359f8"
}
variable "cidr" {
  default = "10.0.0.0/8"
}

# -------------------
# CKAN VARIABLES
# -------------------
variable "acct" {
  description = "AWS account name, such as 'dev' or 'prod' (legacy environment)"
  default     = "prod"
}

variable "vpc" {
  description = "Virtual Private Cloud in the Dev or Prod account / environment"
  default     = ""
}

variable "map_west_vpc" {
  description = "Virtual Private Cloud Map by Dev or Prod account in the west region"
  default     = {
    "dev"     = "dw2dev"
    "dss"     = "dw2ss"
    "prd"     = "pw2prd"
    "pss"     = "pw2ss"
  }
}

variable "map_east_vpc" {
  description = "Virtual Private Cloud Map by Dev or Prod account in the east region"
  default     = {
    "dev"     = "de1dev"
    "dss"     = "de1ss"
    "prd"     = "pe1prd"
    "pss"     = "pe1ss"
  }
}

variable "stack" {
  description = "Tag/Label to distinguish stacks from each other. Used as a naming interfix, and needs to be unique"
  default     = "prd"
}

variable "app" {
  description = "Application tag, name and/or prefix for all resources in a stack"
  default     = "ckan"
}

variable "env" {
  description = "Environment tag, VPC Subnet label, also related to var.acct, ex: 'prod, 'dev', 'stage' (Ansible AMI tag lookup)"
  default     = "dev"
}

variable "lob" {
  description = "Tag for the Line of Business, ex: 'IS'"
  default     = "edci"
}

variable "contact" {
  description = "Tag used to name owner of the resource, in AD username format"
  default     = "hboppudi"
}

variable "apm_id" {
  description = "Tag for APM ID taken from Service Now Application Portfolio Management"
  default     = "APM0001234"
}

variable "contains_pii" {
  description = "Tags, does resource contain pii"
  default     = false
}

variable "contains_pci" {
  description = "Tags, does resource contain pci"
  default     = false
}

variable "owner_group" {
  description = "Owner group for resources created"
  default     = "vdci"
}

variable "cost_center" {
  description = "Tag, FRB specific cost center value, 5 digits"
  default     = "12345"
}

variable "ckan_domain" {
  description = "ckan domain"
  default     = "hrb-qnt"
}

variable "ckan_services" {
  description = "Port configurations for ckan services"
  type        = map
  default     = {
    ssh                       = [{from_port = 22, to_port  = 22, protocol = "tcp"}]
    http                      = [{from_port = 80, to_port  = 80, protocol = "tcp"}]
    https                     = [{from_port = 443, to_port  = 443, protocol = "tcp"}]
    ckan_admin_services       = [{from_port = 8197, to_port  = 8297, protocol = "tcp"},{from_port = 7143, to_port  = 7243, protocol = "tcp"}]
    ckan_docker_registry      = [{from_port = 5000, to_port  = 5000, protocol = "tcp"}]
    ckan_docker_registry_int  = [{from_port = 5100, to_port  = 5100, protocol = "tcp"}]
    ckan_prometheus           = [{from_port = 9100, to_port  = 9100, protocol = "tcp"}]
  }
}

variable "client_aws_security_group_domain_ingress" {
  description = "Mapping of custom ingress rules for the aws_security_group.domain resource"
  type  = map(object({
    description = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default   = {}
}

variable "alb_cert_arn" {
  description = "Certificate for the ALB"
  default     = "arn:aws:acm:us-west-2:432787484136:certificate/84ca4342-4c43-45c5-8ac0-7f4f7f65779e"
}

variable "ckan_private_zone_domain" {
  description = "CKAN Route53 private zonedomain"
  default     = "cloudhari.com"
}

variable "alb_enable" {
  description = "Boolean, enable or disable ALB using input variable"
  default     = "true"
}

variable "alb_count" {
  description = "Number of ALBs to create"
  default     = 1
}

variable "subnets" {
  description = "A list of subnets to associate with the load balancer"
  default     = ["subnet-b778fccf", "subnet-919f3edb"]
}

variable "internal" {
  description = "Boolean determining if the load balancer is internal or externally facing"
  default     = false
}

variable "enable_http2" {
  description = "Indicates whether HTTP/s is enabled in application load balancers"
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
}

variable "backend_ports" {
  description = "It defines Backend Ports for load balancer"
  type        = list(number)
  default     = [8443]
}

variable "backend_protocol" {
  description = "It defines Backend Protocol for load balancer"
  default     = "HTTPS"
}

variable "backend_health_check_paths" {
  description = "It defines Backend health check path for load balancer"
  default     = ["/"]
}

variable "health_interval" {
  description = "It defines health interval for load balancer"
  default     = 30
}

variable "health_timeout" {
  description = "It defines health timeout for load balancer"
  default     = 5
}

variable "health_matcher" {
  description = "It defines health matcher for load balancer"
  default     = 200
}

variable "healthy_threshold" {
  description = "It defines health threshold for load balancer"
  default     = 3
}

variable "unhealthy_threshold" {
  description = "It defines health threshold for load balancer"
  default     = 3
}

variable "listener_ports" {
  description = "It defines listener ports for load balancer"
  type        = list(string)
  default     = [443]
}

variable "listener_protocol" {
  description = "It defines listener protocol for load balancer"
  default     = "HTTPS"
}

variable "listener_cert" {
  description = "It defines listener certificate for load balancer"
  default     = "arn:aws:acm:us-west-2:432787484136:certificate/84ca4342-4c43-45c5-8ac0-7f4f7f65779e"
}

variable "ssl_policy" {
  description = "Optional. It is required for HTTPS"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "redirect_port_80" {
  description = "Port to redirect to, empty string will prevent redirect"
  default     = 443
}

variable "stickiness_type" {
  description = "It defines Stickiness for load balancer"
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "It defines Stickiness Cookie Duration for load balancer"
  default     = 86400
}

variable "stickiness_enabled" {
  description = "It defines Stickiness enabled for load balancer"
  default     = false
}

variable "asg_id" {
  default = ""
}

variable "inst_list" {
  default = []
}

variable "inst_count" {
  default = 0
}

variable "tg_attach" {
  description = "Boolean, set to false so the ALB target group won't get ASG or EC2 instances attached"
  type        = bool
  default     = true
}


variable "ckan_release_buckets" {
  description = "ckan owned S3 buckets"
  default     = [
    "ckan-core-us-east-1",
    "ckan-core-us-west-2",
    "hst-core-dev",
    "hst-core-us-west-2"
    ]
}

variable "create_source_repl_resources" {
  description = "Boolean to create resources for replication of ckan installation files and configs to another account"
  default     = false
}

# -------------------
# -------------------

variable "instance_count" {
  default = 1
}
variable "ami_id" {
  default = "ami-007e276c37b5ff2d7"
}
variable "instance_type" {
  default = "t3.small"
}

variable "environment" {
  default = "sandbox"
}

variable "instance_name" {
  default = "hari-prod-jenkins"
}
variable "key_name" {
  default = "cloud9lakshmi"
}
# variable "key_username" {
#   default = "ubuntu"
# }
# variable "private_key_file" {
#   default = "~/Downloads/cloud9lakshmi.pem"
# }
variable "root_block_device_jenkins_50gb" {
  default = {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }
}

variable "tags" {
  default = {
    Owner         = "hari"
    Environment   = "sandbox"
    InfraLocation = "us-west-2"
  }
}

variable "config_output_path" {
  description = "Where to save the config files `/` ."
  default     = "./local_files/"
}

variable "associate_public_ip_address" {
  default = true
}

#------------------
# KMS KEY SPECIFIC
#------------------

variable key_spec {
  default = "SYMMETRIC_DEFAULT"
}

variable enabled {
  default = true
}
