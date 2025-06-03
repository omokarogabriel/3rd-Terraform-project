#auto-scaling group
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = aws_subnet.private_subnet[*].id
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
  key_name = var.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_http.id,
    aws_security_group.allow_ssh.id
  ]
  user_data = filebase64("${path.module}/user_data.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

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

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}


# ## creeate the rds instance
# resource "aws_db_instance" "rds_instance" {
#   identifier             = "${var.project}-rds-instance"
#   allocated_storage      = var.rds_allocated_storage
#   storage_type           = var.rds_storage_type
#   engine                 = var.rds_engine
#   engine_version         = var.rds_engine_version
#   instance_class         = var.rds_instance_class
#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.allow_rds.id]
#   # username                = var.rds_username
#   # password                = var.rds_password
#   username            = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["username"]
#   password            = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["password"]
#   db_name             = "${var.project}db1"
#   skip_final_snapshot = true

#   tags = {
#     Name        = "${var.project}-rds-instance"
#     Environment = var.environment
#   }
# }
