

#security group for http (port 80)
resource "aws_security_group" "allow_http" {
  name        = "${var.project}-allow-http"
  description = "Allow HTTP access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-allow-http"
    Environment = var.environment

  }

}


#security group for alb (application load balancer)
resource "aws_security_group" "allow_alb" {
  name        = "${var.project}-allow-alb"
  description = "Allow ALB access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-allow-alb"
    Environment = var.environment

  }
}


# #security group for ssh
resource "aws_security_group" "allow_ssh" {
  name        = "${var.project}-allow-ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.project}-allow-ssh"
    Environment = var.environment

  }

}



#security group rule for alb to route traffic to ec2 instances
resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_alb.id
  security_group_id        = aws_security_group.allow_http.id
}



#security group rule for ssh to ec2 instances
resource "aws_security_group_rule" "allow_ssh_to_ec2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_ssh.id
  security_group_id        = aws_security_group.allow_http.id
}



# #security group for rds
# resource "aws_security_group" "allow_rds" {
#   name        = "${var.project}-allow-rds"
#   description = "Allow RDS access"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name        = "${var.project}-allow-rds"
#     Environment = var.environment

#   }
# }

# #security group rule for ec2 instances to rds
# resource "aws_security_group_rule" "allow_ec2_to_rds" {
#   type                     = "egress"
#   from_port                = 3306
#   to_port                  = 3306
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.allow_http.id
#   security_group_id        = aws_security_group.allow_rds.id
# }