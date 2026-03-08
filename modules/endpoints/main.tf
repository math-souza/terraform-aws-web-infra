# Criar VPC Endpoint S3
resource "aws_vpc_endpoint" "webserver-s3-endpoint" {
  vpc_id            = aws_vpc.web-server-vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.priv-rtb-webserver.id
  ]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}
