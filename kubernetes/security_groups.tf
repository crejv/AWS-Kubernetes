# SG for API Load Balancer(ie. Master01:6443, Master01:6443, Master03:6443, ...N)
resource "aws_security_group" "api-elb-k8s-local" {
    name = "api-elb.${local.cluster_name}.k8s.local"
    vpc_id = aws_vpc.containers-vpc.id
    description = "Security Group for api ELB"
    # Allow traffic on port 6443 for API-Server
    ingress{
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        cidr_block  = ["0.0.0.0/0"]
    }
    # Allow icmp traffic such as Ping to reachthe LB
    ingress{
        from_port   = 3
        to_port     = 4
        protocol    = "icmp"
        cidr_block  = ["0.0.0.0/0"]
    }
    # Allow outbound traffic from LB to anywhere
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = ["0.0.0.0/0"]
    }
    # Allow LB to be recognized
    tags = {
        KubernetesCluster   = "${local.cluster_name}.k8s.local"
        Name                = "api-elb.${local.cluster_name}.k8s.local"
    }
}

# SG for Bastion Host to SSH into Maters and Workers Nodes
resource "aws_security_group" "bastion_node" {
    name = "bastion_node"
    vpc_id = aws_vpc.containers-vpc.id
    description = "Allow required traffict to the bastion node"
    
    ingress{
        description = "SSH from outside"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
    }
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
    tags = {
        Name    = "sg_bastion"
    }
}

# SG for Worker Nodes
resource "aws_security_group" "k8s_worker_node" {
    name = "k8s_workers_${local.cluster_name}"
    vpc_id = aws_vpc.containers-vpc.id
    description = "Worker nodes security group"
    
    # Allow all traffict from VPC
    ingress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = [aws_vpc.containers-vpc.cidr_block]
    }

    # Allow all outbound traffic anywhere
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }

    # Tag that Kubernetes recognizes and use SG
    tags = {
        Name                                            = "${local.cluster_name}_nodes"
        "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
}

# SG for Masters
resource "aws_security_group" "k8s_master_nodes" {
    name = "k8s_masters_${local.cluster_name}"
    vpc_id = aws_vpc.containers-vpc.id
    description = "Master nodes security group"
     tags = {
        Name                                            = "${local.cluster_name}_nodes"
        "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    }
}

# Allow traffic from LB-to-Masters
resource "aws_security_group_rule" "traffic_from_lb_to_masters" {
    type                            = "ingress"
    description                     = "Allow API traffic from the Load Balancer"
    from_port                       = 6443
    to_port                         = 6443
    protocol                        = "TCP"
    source_security_group_id        = aws_security_group.api-elb-k8s-local.id
    security_group_id               = aws_security_group.k8s_master_nodes.id
}

# Allow traffic from Workers-to-Masters
resource "aws_security_group_rule" "traffic_from_workers_to_masters" {
    type                            = "ingress"
    description                     = "Traffic from the worker nodes to the master node is allowed"
    from_port                       = 0
    to_port                         = 0
    protocol                        = "-1"
    source_security_group_id        = aws_security_group.k8s_worker_node.id
    security_group_id               = aws_security_group.k8s_master_nodes.id
}

# Allow traffict from bastion-to Masters
resource "aws_security_group_rule" "traffic_from_bastion_to_masters" {
    type                            = "ingress"
    description                     = "Traffic from the bastion node to the master node is allowed"
    from_port                       = 22
    to_port                         = 22
    protocol                        = "TCP"
    source_security_group_id        = aws_security_group.bastion_node.id
    security_group_id               = aws_security_group.k8s_master_nodes.id
}

# Allow outbound traffict for Marters
resource "aws_security_group_rule" "masters_egress" {
    type                            = "egress"
    from_port                       = 0
    to_port                         = 0
    protocol                        = "-1"
    cidr_blocks                     = ["0.0.0.0/0"]
    security_group_id               = aws_security_group.k8s_master_nodes.id
}