data "aws_subnet_ids" "all" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow ingress from Roche network to Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "https port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    description = "http port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user-data" {
  template = "${file("templates/jenkins-user-data.tpl.sh")}"

  vars = {
    environment = "${var.environment}"
  }
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = "${aws_iam_role.jenkins_role.name}"
}


resource "aws_iam_role_policy" "jenkins_policy" {
  name = "jenkins_policy"
  role = "${aws_iam_role.jenkins_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "jenkins-vm" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  vpc_security_group_ids = ["${aws_security_group.jenkins-sg.id}"]
  subnet_id           = "${element(tolist(data.aws_subnet_ids.all.ids), 1)}"
  tags                   = "${merge(var.tags, map("Name", var.instance_name))}"
  user_data              = "${data.template_file.user-data.rendered}"
  iam_instance_profile   = "${aws_iam_instance_profile.jenkins_profile.name}"

  # provisioner "remote-exec" {
  # inline = [
  #   "cloud-init status --wait"
  # ]
  # connection {
  #   type        = "ssh"
  #   user        = "${var.key_username}"
  #   private_key = "${file(var.private_key_file)}"
  #   host         = aws_instance.jenkins-vm.public_ip
  #     }
  #   }
  }


  data "aws_route53_zone" "selected" {
    name         = "cloudhari.com"
  }
  resource "aws_route53_record" "my_name" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name    = "jenkins.${data.aws_route53_zone.selected.name}"
    type    = "A"
    ttl     = "300"
    records = ["${aws_instance.jenkins-vm.public_ip}"]
  }

output "instance_ip"{
        value = "${aws_instance.jenkins-vm.public_ip}"
}

output "jenkins_fqdn" {
  value = "${aws_route53_record.my_name.fqdn}"
}
