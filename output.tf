#alb dns
output "alb_dns" {
  value = aws_alb.alb.dns_name
}

# output "rds_endpoint" {
#   value = aws_db_instance.rds_instance.endpoint
  
# }

# public ec2 ip address
output "public_ec2_ip" {
  value = aws_instance.bastion.public_ip
}