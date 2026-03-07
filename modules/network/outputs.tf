output "vpc_id" {
  value = aws_vpc.webserver_vpc.id
}

output "public_subnets" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnets" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "private_route_table_id" {
  value = aws_route_table.priv.id
}
