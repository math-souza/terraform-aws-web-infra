# Web Servers
resource "aws_instance" "web_a" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id[0]
  vpc_security_group_ids      = var.ec2_sg_id
  iam_instance_profile        = var.instance_profile_name
  user_data_replace_on_change = true

  user_data = templatefile("${path.root}/scripts/userdata.sh", {
    bucket_name = var.bucket_name
  })
  
  tags = {
    name = "web-server-a"
  }

  depends_on = [
    aws_nat_gateway.webserver-nat,
    aws_vpc_endpoint.webserver-s3-endpoint
  ]
}

resource "aws_instance" "web_b" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id[1]
  vpc_security_group_ids      = var.ec2_sg_id
  iam_instance_profile        = var.instance_profile_name
  user_data_replace_on_change = true

  user_data = templatefile("${path.root}/scripts/userdata.sh", {
    bucket_name = var.bucket_name
  })
  
  tags = {
    name = "web-server-b"
  }

  depends_on = [
    aws_nat_gateway.webserver-nat,
    aws_vpc_endpoint.webserver-s3-endpoint
  ]
}
