#load balancer
resource "aws_alb" "alb" {
  name                       = "${var.project}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_alb.id]
  subnets                    = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false


  tags = {
    Name        = "${var.project}-alb"
    Environment = var.environment
  }

}

#target group
resource "aws_alb_target_group" "target_group" {
  name     = "${var.project}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project}-target-group"
    Environment = var.environment
  }
}

#listener
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }

  tags = {
    Name        = "${var.project}-listener"
    Environment = var.environment
  }
}

