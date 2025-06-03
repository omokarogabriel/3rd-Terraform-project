variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

}

variable "environment" {
  description = "Development environment"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the project"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)

}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

}

variable "region" {
  description = "value of the region"
  type        = string
}

variable "asg_desired_capacity" {
  description = "number of instances in the auto-scaling group"
  type        = number
}

variable "asg_max_size" {
  description = "maximun size of the auto-scaling group"
  type        = number
}

variable "asg_min_size" {
  description = "minimum size of the auto-scaling group"
  type        = number
}

variable "ami_id" {
  description = "the ami image"
  type        = string
}

variable "instance_type" {
  description = "instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair to use for the instance"
  type        = string
}

# variable "rds_allocated_storage" {
#   description = "allocated storage for RDS"
#   type        = number
#   default     = 20
# }

# variable "rds_storage_type" {
#   description = "storage type for RDS"
#   type        = string
#   default     = "gp3"

# }

# variable "rds_engine" {
#   description = "RDS engine type"
#   type        = string
#   default     = "mysql"

# }

# variable "rds_engine_version" {
#   description = "RDS engine version"
#   type        = string
#   default     = "8.0"
# }
# variable "rds_instance_class" {
#   description = "RDS instance class"
#   type        = string
#   default     = "db.t3.micro"
# }

# variable "rds_username" {
#   description = "RDS master username"
#   type        = string
#   sensitive   = true
#   validation {
#     condition     = length(var.rds_username) >= 1
#     error_message = "RDS username must be at least 1 character long."
#   }
# }

# variable "rds_password" {
#   description = "RDS master password"
#   type        = string
#   sensitive   = true
# }


