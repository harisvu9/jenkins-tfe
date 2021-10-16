provider "aws" {
  region     = "${var.region}"
}

variable "region" {
  default = "us-west-2"
}
variable "vpc_id" {
  default = "vpc-807359f8"
}
variable "cidr" {10.0.0.0/8}

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
  default = "dev"
}

variable "instance_name" {
  default = "hari-prod-jenkins"
}
variable "key_name" {
  default = "cloud9lakshmi"
}

variable "root_block_device_jenkins_50gb" {
  default = {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }
}

variable "config_output_path" {
  description = "Where to save the config files `/` ."
  default     = "./local_files/"
}

variable "associate_public_ip_address" {
  default = true
}
