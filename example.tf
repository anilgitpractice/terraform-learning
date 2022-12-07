provider "aws" {
  region = "us-east-1"

}
resource "aws_default_vpc" "default" {}

resource "aws_security_group" "prod-web-servers-sg" {
  name        = "prod-web-servers-sg"
  description = "security group for production grade web servers"
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
  }

  ingress {
    description      = "MYSQL"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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



#Subnet

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.0.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_instance" "prod-web-server" {
  ami                    = "ami-0574da719dca65348"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.prod-web-servers-sg.id]
  subnet_id              = aws_subnet.private_subnet.id
tags = {
  Name = "terrafromlearning"
  }
}
# creating ebs volume
resource "aws_ebs_volume" "volume-1" {
 availability_zone = "us-east-1b"
 type = "gp2"
 size = 8
 tags = {
    Name = "myebsvolume"
 }
}
# Attaching ebs volume
resource "aws_volume_attachment" "volume-1-attachment" {
 device_name = "/dev/xvdh"
 volume_id = "${aws_ebs_volume.volume-1.id}"
 instance_id = "${aws_instance.prod-web-server.id}"
}

