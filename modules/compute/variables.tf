variable "bucket_name" {
  type = string
  default = "website-project-matheus"
}

variable "ami_id" {
  type = string
  default = "ami-0c1fe732b5494dc14"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
}


variable "ec2_sg_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
