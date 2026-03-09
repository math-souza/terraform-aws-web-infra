output "vpc_id" {
  value = aws_vpc.web-server-vpc.id
}

output "pub_sub_1a" {
  value = aws_subnet.pub-sub-1a-webserver.id
}

output "pub_sub_1b" {
  value = aws_subnet.pub-sub-1b-webserver.id
}

output "priv_sub_1a" {
  value = aws_subnet.priv-sub-1a-webserver.id
}

output "priv_sub_1b" {
  value = aws_subnet.priv-sub-1b-webserver.id
}

output "private_route_table_id" {
  value = aws_route_table.priv-rtb-webserver.id
}

output "public_route_table_id" {
  value = aws_route_table.pub-rtb-webserver.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.webserver-nat.id
}
