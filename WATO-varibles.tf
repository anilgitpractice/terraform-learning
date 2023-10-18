# variables.tf

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "ami" {
  type    = string
  default = "ami-0e83be366243f524a"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_name_prefix" {
  type    = string
  default = "my-instance"
}
variable "key_name" {
  type    = string
  default = "tomcatcluster"
