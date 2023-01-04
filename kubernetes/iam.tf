# Generate Type of Trusted Entity
data "aws_iam_policy_document" "trust-assume-role-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        # Trusted Entities- Role Trust the ec2 to assume Role
        principals {
            identifiers = ["ec2.amazonaws.com"]
            type        = "service"
        }
    }
}

#Create Master Role
resource "aws_iam_role" "terraform_k8s_master_role" {
    name                = "terrafrom_master_role"
    path                ="/"
    assume_role_policy  = data.aws_iam_policy_document.trust-assume-role-policy.json
    managed_policy_arns = var.iam-master-role-policy-attachment 
}

#Create Worker Role
resource "aws_iam_role" "terraform_k8s_worker_role" {
    name                = "terrafrom_worker_role"
    path                ="/"
    assume_role_policy  = data.aws_iam_policy_document.trust-assume-role-policy.json
    managed_policy_arns = var.iam-worker-role-policy-attachment 
}


# Configure IAM Master instance profile
resource "aws_iam_instance_profile" "terraform_k8s_master_role-Instance-Profile" {
    name = "terraform_maser_role-Instance-Profile"
    role = aws_iam_role.terraform_k8s_master_role.name
}
# Configure IAM Worker instance profile
resource "aws_iam_instance_profile" "terraform_k8s_worker_role-Instance-Profile" {
    name = "terraform_cluster-iam-worker-Instance-Profile"
    role = aws_iam_role.terraform_k8s_worker_role.name
}