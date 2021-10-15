provider "aws" {
  region     = "${var.region}"
}

variable "region" {
  default = ""
}
variable "vpc_id" {
  default = ""
}
variable "cidr" {}

variable "instance_count" {
  default = 1
}
variable "ami_id" {
  default = ""
}
variable "instance_type" {
  default = "t2.micro"
}

variable "environment" {
  default = ""
}

variable "instance_name" {
  default = "hari-prod-jenkins"
}
variable "key_name" {
  default = ""
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
