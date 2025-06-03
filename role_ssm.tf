# This Terraform configuration creates an IAM role for EC2 instances to use AWS Systems Manager (SSM) and CloudWatch Agent.
resource "aws_iam_role" "ec2_ssm_role" {
  name        = "ec2_ssm_role"
  description = "IAM role for EC2 instances to use SSM and CloudWatch Agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


## Attach the necessary policies to the IAM role for SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


## Attach the CloudWatch Agent policy to the IAM role
resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# Create an IAM instance profile to associate the role with EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

#s3 bucket for user data script
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


#ssm document for user data

resource "aws_ssm_parameter" "cw_agent_config" {
  name  = "/CWAgent/config"
  type  = "String"
  value = file("./cwagent_config.json")
}





# #create a secret for rds credentials
# resource "aws_secretsmanager_secret" "rds_credentials" {
#   name        = "rds-credentials"
#   description = "RDS credentials for the application"
# }
# resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
#   secret_id = aws_secretsmanager_secret.rds_credentials.id
#   secret_string = jsonencode({
#     username = var.rds_username
#     password = var.rds_password
#   })
# }
# # iam policy for secretsmanager
# resource "aws_iam_policy" "secrets_policy" {
#   name        = "${var.project}-secrets-policy"
#   path        = "/"
#   description = "Allow EC2 instances to access Secrets Manager secrets"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Effect   = "Allow"
#         Resource = [
#           aws_secretsmanager_secret.rds_credentials.arn
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = aws_iam_policy.secrets_policy.arn
# }


