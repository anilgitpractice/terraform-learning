provider "aws" {
  region = "us-east-1"
  
}

# Main VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}
# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}
# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "private Subnet"
  }
}
#Internat Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-vpc IGW"
  }
}
# Elastic IP 
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP"
  }
}
# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "my-vpc NAT Gateway"
  }
}
# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}
# Private Subnet and Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# creating  security gruop using terraform

resource "aws_security_group" "TF_SG" {
  name        = "security gruop using terraform"
  description = "security gruop using terraform"
  vpc_id      = aws_vpc.my-vpc.id

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
    Name = "TF_SG"
  }
}
# creating a ec2instance

resource "aws_instance" "my-ec2" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = ["aws_security_group.mysecurity.name"]

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
 instance_id = "${aws_instance.my-ec2.id}"
}


