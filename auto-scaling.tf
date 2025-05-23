#auto-scaling group
resource "aws_autoscaling_group" "asg" {
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  vpc_zone_identifier       = aws_subnet.private_subnet[*].id
    #   launch_configuration      = aws_launch_configuration.lc.id
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_alb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

# #launch configuration
# resource "aws_launch_configuration" "lc" {
#   name                        = "${var.project}-lc"
#   image_id                    = var.ami_id
#   instance_type               = var.instance_type
#   security_groups             = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
#   associate_public_ip_address = false
#   user_data                   = file("user_data.sh")


#   lifecycle {
#     create_before_destroy = true
#   }

# }

#launch template
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
      aws_security_group.allow_http.id,
      aws_security_group.allow_ssh.id
    ]
  user_data = filebase64("${path.module}/user_data.sh")
#   associate_public_ip_address = false
  

  lifecycle {
    create_before_destroy = true
  }

    tag_specifications {
        resource_type = "instance"
        tags = {
        Name        = "${var.project}-lt"
        Environment = var.environment
        }
    }

}


# aws automatic scaling policy





