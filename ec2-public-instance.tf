# bastion host
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  subnet_id = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true

  tags = {
    Name = "BastionHost"
  }
  
}


# aws secret manager secret for bastion host
# resource "aws_secretsmanager_secret" "bastion_host_secret" {
#   name        = "${var.project}-bastion-host-secret"
#   description = "Secret for Bastion Host"
#   tags = {
#     Name        = "${var.project}-bastion-host-secret"
#     Environment = var.environment
#   }
# }

data "aws_secretsmanager_secret" "github_ssh_key" {
  name = "github_ssh_private_key"
#   description = "SSH private key for GitHub access"
}

data "aws_secretsmanager_secret_version" "github_ssh_key_version" {
  secret_id = data.aws_secretsmanager_secret.github_ssh_key.id
}

#github policy attached to the bastion host
# resource "aws_iam_policy" "github_access_policy" {
#   name        = "${var.project}-github-access-policy"
#   description = "Policy to allow access to GitHub via SSH"
  
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         "Sid": "AllowReadAccessToGitHubSSHKey",
#         "Effect"   = "Allow",
#         "Action "  = ["secretsmanager:GetSecretValue"],
#         "Resource" = aws_secretsmanager_secret.github_ssh_key.arn
#       }
#     ]
# #       "Statement": [
# #     {
# #       "Sid": "AllowReadAccessToGitHubSSHKey",
# #       "Effect": "Allow",
# #       "Action": [
# #         "secretsmanager:GetSecretValue"
# #       ],
# #       "Resource": "arn:aws:secretsmanager:YOUR_REGION:YOUR_ACCOUNT_ID:secret:github_ssh_private_key-*"
# #     }
# #   ]

#   })
# }

resource "aws_iam_policy" "github_ec2_access_policy" {
  name        = "${var.project}-github-ec2-access-policy"
  description = "Policy to allow EC2 instance to access GitHub SSH key from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowReadAccessToGitHubSSHKey",
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = data.aws_secretsmanager_secret.github_ssh_key.arn

      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_github_access_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.github_ec2_access_policy.arn
}

