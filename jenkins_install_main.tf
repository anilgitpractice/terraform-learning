terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "custom-sg" {
  name        = "custom-sg"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "WEBSERVER"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysecurity"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.0.0/20"
  availability_zone = "us-east-2a"
}

#creating ec2 instance

resource "aws_instance" "web_instance" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  key_name      = "tomcatcluster"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/path/to/your/private_key.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-17-jdk",
      "wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo apt-get install -y nginx"
    ]
  }

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.custom-sg.id]
  associate_public_ip_address = true
tags = {
  Name = "terrafromlearning"
  }
}
