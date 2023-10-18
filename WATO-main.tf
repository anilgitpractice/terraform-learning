# configured aws provider with proper credentials
provider "aws" {
  region    = var.region
  profile   = var.profile
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
  }
}
# create security group for the ec2 instance
resource "aws_security_group" "web_sg" {
  name        = "ec2 security group"
  description = "allow access on ports 80,8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 80
  ingress {
    description      = "http proxy access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 8080
  ingress {
    description      = "jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "terraformtask1"
  }
}
# launch the ec2 instance and install website
resource "aws_instance" "web_instance" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
tags = {
  Name = "${var.instance_name_prefix}-${count.index + 1}"
}


  provisioner "local-exec" {
    command = "echo 'Instances Information:' > task.txt"
  }
}
resource "null_resource" "instance_info" {
  count = var.instance_count

  provisioner "local-exec" {
    command = <<EOT
      echo "Instance Name: ${aws_instance.web_instance[count.index].tags.Name}" >> task.txt
      echo "Instance ID: ${aws_instance.web_instance[count.index].id}" >> task.txt
      echo "Private IP: ${aws_instance.web_instance[count.index].private_ip}" >> task.txt
      echo "Public IP: ${aws_instance.web_instance[count.index].public_ip}" >> task.txt
      echo "" >> task.txt
    EOT
  }
}
