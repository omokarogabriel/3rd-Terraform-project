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