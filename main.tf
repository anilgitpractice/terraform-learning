provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "my_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my Custom VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.my_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.my_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name = "mysecurity"
  } 
}

resource "aws_instance" "web_instance" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  key_name      = "terraform"

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
tags = {
  Name = "terrafromlearning"
  }
}
# creating ebs volume
resource "aws_ebs_volume" "volume-1" {
 availability_zone = "us-east-1a"
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
 instance_id = "${aws_instance.web_instance.id}"
}

