module "kubernetes" {
  source = "./kubernetes/vpc"
  vpc_cidr_block = "10.16.0.0/16"
}

