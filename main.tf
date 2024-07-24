# main.tf

provider "aws" {
  region = "us-east-2" # Specify your desired AWS region
}

resource "aws_security_group" "example_sg" {
  name        = "example-security-group"
  description = "Example security group for SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
  vpc_security_group_ids      = [aws_security_group.example_sg.id]
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

resource "aws_elb" "example_elb" {
  name               = "example-elb"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"] # Specify the desired availability zones

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 2
    timeout             = 5
  }

  instances = [aws_instance.example_instance.id]
}

data "aws_vpc" "default" {
  default = true
}
