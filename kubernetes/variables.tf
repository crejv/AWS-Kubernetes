variable "vpc_cidr_block" {
    type = string
}
variable "vpc_name" {
    type = string
    default = "containers-vpc"
}
variable "cluster_name" {
    type = string
    default = "k8s_demo"
}
variable "region"{
    type = string
    default = "us-west-2"
}
variable "private_subnet01_netnum" {
    type = string
}
variable "public_subnet01_netnum" {
    type = string 
}

# Define Policy. Policy consist list of AWS managed polices
variable "iam-master-role-policy-attachment" {
  type        = list(string)
  description = "Master List of IAM policies"
  # Policies
  default     = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}
variable "iam-worker-role-policy-attachment" {
  type        = list(string)
  description = "Master List of IAM policies"
  # Policies
  default     = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}