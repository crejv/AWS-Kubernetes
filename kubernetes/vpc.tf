resource "aws_vpc" "containers_vpc" {
    cidr_block  = var.vpc_cidr_block
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_vpc_dhcp_options" "dhcpos" {
    domain_name         = "${var.region}.compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]
}
    
