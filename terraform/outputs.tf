output "load_balancer_hostname" {
  value = aws_lb.default.dns_name
}

# output "bastion_public_ip" {
#   value = aws_instance.bastion.public_ip
# }

# output "s3_name" {
#   value = aws_s3_bucket.default.id
# }