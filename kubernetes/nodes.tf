# Initialize Instance Deployment
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
#   iam_instance_profile = var.iam_instance_profile
  key_name             = aws_key_pair.my_key.key_name
#   user_data            = var.user_data

  subnet_id            = aws_subnet.utility.id
  security_groups      = [aws_security_group.bastion.node.id]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "bastion.${local.custer_name}"
  }
}

########### KEY PAIR####################
#Define public key to share on the server
resource "aws_key_pair" "my_key" {
  key_name   = "k8s_key"
  public_key = tls_private_key.my_key.public_key_openssh
}

#RSA key of size 4096 bits
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Store Private Key to Local File
resource "local_file" "my_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "my_private_key"
}

# Retreive the Latest Image for Amazon-AWS-Linux Image
data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["09972019477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-sever-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


resource "aws_elb" "api-k8s-local" {
    name = "api-${local.cluster_name}"

    listener {
        instance_port       = 6443
        instance_protocol   = "TCP"
        lb_port             = 6443
        lb_protocol         = "TCP"
    }
    security_groups     = [aws_security_group.api-elb-k8s-local.id]
    subnets             = [aws_subnet.public01.id]

    health_check {
        target              = "SSL:6443"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 10
        timeout             = 5
    }

    cross_zone_load_balancing   = true
    idle_timeout                = 300

    tags = {
        kubernetesCluster                               = local.cluster_name
        Name                                            = "api.${local.cluster_name}"
        "kubernetes.io/cluster/${local.cluster_name}"   = "owned"
    }
}

resource "aws_launch_configuration" "masters-az01-k8s-local" {
    name_prefix             = "masters.${local.cluster_name}"
    image_id                = var.ami
    instance_type           = "t3.small"
    key_name                = aws_key_pair.my_key.key_name
    iam_instance_profile    = aws_iam_instance_profile.terraform_k8s_master_role-Instance-Profile.id
    security_groups         = [aws_security_group.k8s_master_nodes.id]
    user_data               = <<EOT
    #!/bin/bash
    hostnamectl set-hostname --static "$(curl -s http:169.254.169.254/latest/meta-data/local-hostname)"
    EOT
    lifecycle {
        create_before_destroy   = true
    }
    root_block_device {
        volume_type             = "gp2"
        volume_size              = 20
        delete_on_termination   = true
    }
}

resource "aws_autoscaling_group" "master-k8s-local-01" {
    name                    = "${local.cluster_name}_masters"
    launch_configuration    = aws_launch_configuration.masters-az01-k8s-local.id
    max_size                = 1
    min_size                = 1
    vpc_zone_identifier     = [aws_subnet.private01.id]
    load_balancers          = [aws_elb.api-k8s-local.id]

    tags = [{
        key                 = "KubernetesCluster"
        value               = local.cluster_name
        propagate_at_launch = true
    },
    {
      key                   = "Name"
      value                 = "masters.${local.cluster_name}"
      propagate_at_launch   = true
    },
    {
      key                   = "k8s.io/role/master"
      value                 = "1"
      propagate_at_launch   = true
    },
    {
      key                   = "kubernetes.io/cluster/${var.cluster_name}"
      value                 = "1"
      propagate_at_launch   = true
    }
  ]
}


resource "aws_launch_configuration" "worker-k8s-local" {
    name_prefix             = "nodes.${local.cluster_name}"
    image_id                = var.ami
    instance_type           = "t3.small"
    key_name                = aws_key_pair.my_key.key_name
    iam_instance_profile    = aws_iam_instance_profile.terraform_k8s_worker_role-Instance-Profile.id
    security_groups         = [aws_security_group.k8s_master_nodes.id]
    user_data               = <<EOT
    #!/bin/bash
    hostnamectl set-hostname --static "$(curl -s http:169.254.169.254/latest/meta-data/local-hostname)"
    EOT
    lifecycle {
        create_before_destroy   = true
    }
    root_block_device {
        volume_type             = "gp2"
        volume_size              = 20
        delete_on_termination   = true
    }
}

resource "aws_autoscaling_group" "nodes-k8s" {
    name                    = "${local.cluster_name}_workers"
    launch_configuration    = aws_launch_configuration.masters-az01-k8s-local.id
    max_size                = 1
    min_size                = 1
    vpc_zone_identifier     = [aws_subnet.private01.id]
   
    tags = [{
        key                 = "KubernetesCluster"
        value               = local.cluster_name
        propagate_at_launch = true
    },
    {
      key                   = "Name"
      value                 = "nodes.${local.cluster_name}"
      propagate_at_launch   = true
    },
    {
      key                   = "k8s.io/role/node"
      value                 = "1"
      propagate_at_launch   = true
    },
    {
      key                   = "kubernetes.io/cluster/${var.cluster_name}"
      value                 = "1"
      propagate_at_launch   = true
    }
  ]
}