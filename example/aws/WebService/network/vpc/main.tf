locals "az_num" {
    a = 0
    b = 1
    c = 2
    d = 3
}

data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    vpc = {
        name = "vpc-y2net-prd-an2"
        cidr = "10.20.0.0/24"
        # id = aws_vpc.vpc-y2net-prd-an2.id
    }

    ## Subnet
    sbns = [
        {
            
        },
        {

        },
        {

        },
        {

        }
    ]
}




##### VPC #####
resource "aws_vpc" "vpc-y2net-prd-an2" {

    cidr_block = local.vpc["cidr"]

    # IPv6 CIDR Block 사용여부
    assign_generated_ipv6_cidr_block = "false"

    # 전용 테넌시 인스턴스 사용
    instance_tenancy = "default"

    # DNS 사용
    enable_dns_hostnames = "true"
    enable_dns_support = "true"

    # enable_classiclink = "false"
    # enable_classiclink_dns_support = "false"

    tags = {
        Name : local.vpc["name"]
    }
}