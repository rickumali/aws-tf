# main.tf

provider "aws" {
  region = "us-east-2" # Specify your desired AWS region
}

resource "aws_security_group" "ec2_secgrp" {
  name        = "ec2-security-group"
  description = "Example security group for SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  // Inbound HTTP comes from ELB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_secgrp.id]
  }

  // This enables full egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_secgrp" {
  name        = "elb-security-group"
  description = "Example security group for ELB with SSL Termination"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This enables full egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "example_instance" {
  ami = "ami-092b51d9008adea15" # Specify the desired AMI ID
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }
  instance_type               = "t2.medium" # Specify the desired instance type
  key_name                    = "rick-pair"
  vpc_security_group_ids      = [aws_security_group.ec2_secgrp.id]
  user_data                   = <<-EOF
              #!/bin/bash
              yum -q -y update
              yum -q -y install nginx docker.x86_64
              systemctl enable nginx.service
              systemctl start nginx.service
              usermod -a -G docker ec2-user
              systemctl enable docker.service
              systemctl start docker.service
              curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
              curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              install -o root -g docker ./kubectl /usr/local/bin/kubectl
              wget https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
              tar -zxf k9s_Linux_amd64.tar.gz k9s
              install -o root -g docker ./k9s /usr/local/bin
  EOF
  user_data_replace_on_change = true

  tags = {
    Name = "example-instance"
  }
}

resource "aws_lb_target_group" "http_target" {
  name     = "http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    healthy_threshold   = "3"
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
    interval            = "30"
    unhealthy_threshold = "2"
  }
}

# Listener
resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_target.arn
  }
}

locals {
  first_cert      = slice(var.test_subdomain_names, 0, 1)
  remaining_certs = slice(var.test_subdomain_names, 1, length((var.test_subdomain_names)))
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.devcert[local.first_cert[0]].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_target.arn
  }
}

resource "aws_lb_listener_certificate" "otherdomain" {
  for_each        = toset(local.remaining_certs)
  listener_arn    = aws_lb_listener.front_end_https.arn
  certificate_arn = data.aws_acm_certificate.devcert[each.value].arn
}

resource "aws_lb" "example_alb" {
  name               = "example-alb"
  load_balancer_type = "application"

  security_groups = [aws_security_group.elb_secgrp.id]
  subnets         = [for s in data.aws_subnet.subnet : s.id]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.value
}

resource "aws_lb_target_group_attachment" "lb_attachment" {
  target_group_arn = aws_lb_target_group.http_target.arn
  target_id        = aws_instance.example_instance.id
  port             = 80
}
