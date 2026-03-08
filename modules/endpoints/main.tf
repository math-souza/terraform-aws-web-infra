# Criar VPC Endpoint S3
resource "aws_vpc_endpoint" "webserver-s3-endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = var.endpoint_type

  route_table_ids = [
    var.priv_rtb_id
  ]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}
