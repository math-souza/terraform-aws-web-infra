# Web Servers
resource "aws_instance" "web_a" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1a-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
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
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1b-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
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
