data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

data "template_file" "user-data" {
  template = "${file("templates/jenkins-user-data.tpl.sh")}"

  vars = {
    environment = "${var.environment}"
  }
}

resource "aws_instance" "admin_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  # vpc_security_group_ids = [aws_security_group.admin.id, aws_security_group.domain.id]
  security_groups        = concat([aws_security_group.admin.name, aws_security_group.domain.name])
  # security_groups        = ["hst-admin"]
  subnet_id              = "${element(tolist(data.aws_subnet_ids.all.ids), 1)}"
  tags                   = "${merge(var.tags, tomap({"Name" = var.instance_name}))}"
  user_data              = "${data.template_file.user-data.rendered}"
  # iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name
  iam_instance_profile   = local.admin_hst_role_name
  #
  #
  # additional_tags        = {
  #   "hst_account_name"    = var.ckan_domain
  #   "hst_domain"          = var.ckan_domain
  #   "hst_env"             = "qnt"
  #   "hst_name"            = "admin-${var.ckan_domain}-1"
  # }

  # provisioner "remote-exec" {
  # inline = [
  #   "cloud-init status --wait"
  # ]
  # connection {
  #   type        = "ssh"
  #   user        = "${var.key_username}"
  #   private_key = "${file(var.private_key_file)}"
  #   host         = aws_instance.admin_ec2.public_ip
  #     }
  #   }
  }


  # data "aws_route53_zone" "selected" {
  #   name         = "cloudhari.com"
  # }
  # resource "aws_route53_record" "my_name" {
  #   zone_id = "${data.aws_route53_zone.selected.zone_id}"
  #   name    = "jenkins.${data.aws_route53_zone.selected.name}"
  #   type    = "A"
  #   ttl     = "300"
  #   records = ["${aws_instance.admin_ec2.public_ip}"]
  # }

output "instance_ip"{
        value = "${aws_instance.admin_ec2.public_ip}"
}

# output "jenkins_fqdn" {
#   value = "${aws_route53_record.my_name.fqdn}"
# }
