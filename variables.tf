variable "aws_region" {
  description = "AWS region for the lab."
  type        = string
}

variable "project_name" {
  description = "Prefix used for resource names and tags."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for bastion, web, and backend instances."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name used for SSH access."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = var.vpc_cidr != "10.0.0.0/16"
    error_message = "The VPC CIDR must not be 10.0.0.0/16."
  }
}

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "Two CIDR blocks for the private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDR blocks."
  }
}

variable "ssm_string_name" {
  description = "Path for the plain-text SSM parameter."
  type        = string
}

variable "ssm_string_value" {
  description = "Value for the plain-text SSM parameter."
  type        = string
}

variable "ssm_secure_name" {
  description = "Path for the secure SSM parameter."
  type        = string
}

variable "ssm_secure_value" {
  description = "Value for the secure SSM parameter."
  type        = string
  sensitive   = true
}
