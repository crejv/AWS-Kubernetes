data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_subnet" "private01" {
    vpc_id                  = aws_vpc.containers_vpc.id
    map_public_ip_on_launch = false
    cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.private_subnet01_netnum)
    aws_availability_zone   = element(data.aws_availability_zones.available.names, 0)
    tags = {
        Name                                        = "private-subnet01-${var.cluster_name}"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"           = "1"
    }
}

resource "aws_subnet" "public01" {
    vpc_id                  = aws_vpc.containers_vpc.id
    map_public_ip_on_launch = true
    cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.public_subnet01_netnum)
    aws_availability_zone   = element(data.aws_availability_zones.available.names, 0)
    tags = {
        Name                                        = "public-subnet01-${var.cluster_name}"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                    = "1"
    }
}

