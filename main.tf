module "kubernetes" {
  source "./kubernetes"
}

resource "aws_vpc" "Containers VPC" {
  cidr_block = "10.16.0.0/16"
}
