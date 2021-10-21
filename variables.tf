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
variable "ckan_services" {
  description = "Port configurations for ckan services"
  type        = map
  default     = {
    ssh                     = [{from_port = 22, to_port  = 22, protocol = "tcp"}]
    http                    = [{from_port = 80, to_port  = 80, protocol = "tcp"}]
    https                   = [{from_port = 443, to_port  = 443, protocol = "tcp"}]
    ckan_admin_services     = [{from_port = 8197, to_port  = 8297, protocol = "tcp"}]
    ckan_docker_registry    = [{from_port = 5000, to_port  = 5000, protocol = "tcp"}]
    beacon_prometheus       = [{from_port = 9100, to_port  = 9100, protocol = "tcp"}]
  }
}
# -------------------
# CKAN VARIABLES
# -------------------
variable "vpc" {
  description = "Virtual Private Cloud in the Dev or Prod account / environment"
  default     = ""
}

variable "stack" {
  description = "Tag/Label to distinguish stacks from each other. Used as a naming interfix, and needs to be unique"
  default     = "qnt"
}

variable "ckan_domain" {
  description = "ckan domain"
  default     = "hrb-qnt"
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
