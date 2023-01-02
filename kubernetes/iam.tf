data "aws_iam_policy_document" "trust-assume-role-policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            identifiers = ["ec2.amazonaws.com"]
            type        = "service"
        }
    }
}

resource "aws_iam_role" "terraform_k8s_master_role" {
    name                = "terrafrom_master_role"
    assume_role_policy  = data.aws_iam_policy_document.trust-assume-role-policy.json
}



resource "aws_iam_instance_profile" "terraform_k8s_master_role-Instance-Profile" {
    name = "terraform_maser_role-Instance-Profile"
    role = aws_iam_role.terraform_k8s_master_role.name
}
resource "aws_iam_instance_profile" "terraform_k8s_worker_role-Instance-Profile" {
    name = "terraform_cluster-iam-worker-Instance-Profile"
    role = aws_iam_role.terraform_k8s_worker_role.name
}