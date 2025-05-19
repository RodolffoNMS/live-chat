output "vpc_id" {
  value = aws_vpc.livechat-vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}