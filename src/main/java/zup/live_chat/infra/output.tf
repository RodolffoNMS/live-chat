output "vpc_id" {
  value = aws_vpc.livechat-vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "alb_dns" {
  value = aws_lb.alb-livechat.dns_name
}

output "apigateway_dns" {
  value = aws_apigatewayv2_api.livechat.api_endpoint
}