provider "aws" {}

provider "aws" {
  assume_role {
    role_arn = var.custom_role
  }
}

variable "custom_role" {
  description = "arn to assume role [TF_VAR_foo=bar]"
}


module "kubernetes" {
  source = "./kubernetes"
  vpc_cidr_block = "10.16.0.0/16"
}

