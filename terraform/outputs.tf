output "alb_hostname" {
  value = aws_lb.load_balancer.dns_name
}

output "alb_hostname_id" {
  value = aws_lb.load_balancer.id
}

output "ecs_id" {
  value = aws_ecs_cluster.cluster.name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}