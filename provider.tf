# Setup terraform provider(s) and version
# Assume Role
# Define Variable(s)
# VPC Proof of Concept Deployment

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

provider "aws" {
  assume_role {
    role_arn = var.custom_role
  }
}

variable "custom_role" {
  description = "arn to assume role [TF_VAR_foo=bar]"
}
