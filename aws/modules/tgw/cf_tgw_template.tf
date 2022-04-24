resource "aws_vpc" "vpc" {

    cidr_block = var.vpc_cidr

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
        Name : var.vpc_name
    }
}

resource "aws_subnet" "sbn-a" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.priSub[0].cidr
    availability_zone = var.azs[0]
    assign_ipv6_address_on_creation = false
    tags={
        Name : var.priSub[0].name
    }
}

resource "aws_subnet" "sbn-c" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.priSub[1].cidr
    availability_zone = var.azs[1]
    assign_ipv6_address_on_creation = false
    tags={
        Name : var.priSub[1].name
    }    
}


resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = var.priRt
    }
}


resource "aws_route_table_association" "rt-asso-pri-a" {
    subnet_id = aws_subnet.sbn-a.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt-asso-pri-c" {
    subnet_id = aws_subnet.sbn-c.id
    route_table_id = aws_route_table.rt.id
}

###########################
# Application Load Balancer
resource "aws_lb" "alb" {
    name               = "alb-web-dev-an2"
    internal           = "true"
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg_pub.id]
    subnets = [aws_subnet.sbn-a.id, aws_subnet.sbn-c.id]
    /*
    subnet_mapping {
        subnet_id     = aws_subnet.sbn-a.id
    }
    subnet_mapping {
        subnet_id     = aws_subnet.sbn-c.id
    }*/

    enable_deletion_protection = false

    idle_timeout = 60
    enable_http2 = "true"
    ip_address_type = "ipv4"

    tags = {
        Name = "alb-web-dev-an2"
        Environment = "development"
    }
}


# Security Group

resource "aws_security_group" "sg_pub" {
    name        = "secgrp-web-dev-an2"
    description = "Allow 80, 22, ICMP inbound traffic"
    vpc_id      = aws_vpc.vpc.id

    tags = {
        Name = "sg-web-dev-an2"
    }
}

resource "aws_security_group_rule" "sg_http" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_pub.id
}

resource "aws_security_group_rule" "sg_ssh" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_pub.id
}

resource "aws_security_group_rule" "sg_outbound" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.sg_pub.id
}

## Transit Gateway attach
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attch" {
    subnet_ids         = [aws_subnet.sbn-a.id, aws_subnet.sbn-c.id]
    transit_gateway_id = var.tgw_id
    vpc_id             = aws_vpc.vpc.id

    dns_support = "enable"
    ipv6_support = "disable"

    # 
    transit_gateway_default_route_table_association = "false"
    transit_gateway_default_route_table_propagation = "false"

    tags = {
        Name = "tgw-attach-dev-an2"
    }    
}

### VPC 연결 1개당 Routing Table 1개 필요
/*
resource "aws_ec2_transit_gateway_route_table" "tgw-rt" {
    transit_gateway_id = var.tgw_id

    tags = {
        Name = "tgw-rt-dev-an2"
    }    
}*/

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc" {
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = var.tgw_rt_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_propa" {
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = var.tgw_rt_id
}

resource "aws_ec2_transit_gateway_route" "tgw-rt-rule" {
    destination_cidr_block         = "10.20.10.0/24"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = var.tgw_rt_id
}

resource "aws_route" "r" {
    route_table_id = aws_route_table.rt.id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
}


resource "aws_vpc" "vpc" {

    cidr_block = var.vpc_cidr

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
        Name : var.vpc_name
    }
}

resource "aws_subnet" "sbn-a" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pubSub[0].cidr
    availability_zone = var.azs[0]
    assign_ipv6_address_on_creation = false
    tags={
        Name : var.pubSub[0].name
    }
}

resource "aws_subnet" "sbn-c" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pubSub[1].cidr
    availability_zone = var.azs[1]
    assign_ipv6_address_on_creation = false
    tags={
        Name : var.pubSub[1].name
    }    
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "igw-net-prd-an2"
    }
}

resource "aws_route_table" "rt_a" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = var.pubRt
    }
    depends_on = [
        aws_internet_gateway.igw
    ]
}

resource "aws_route" "r_a" {
    route_table_id = aws_route_table.rt_a.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-c.id
}

resource "aws_route_table_association" "rt-asso-pri-a" {
    subnet_id = aws_subnet.sbn-a.id
    route_table_id = aws_route_table.rt_a.id
}

resource "aws_route_table" "rt_c" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "rt-net-prd-an2-pub-c"
    }
    depends_on = [
        aws_internet_gateway.igw
    ]
}

resource "aws_route" "r_c" {
    route_table_id = aws_route_table.rt_c.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rt-asso-pub-c" {
    subnet_id = aws_subnet.sbn-c.id
    route_table_id = aws_route_table.rt_c.id
}


resource "aws_route" "tgw-rt-r-prd" {
    route_table_id = aws_route_table.rt_c.id
    destination_cidr_block = "10.20.20.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "tgw-rt-r-dev" {
    route_table_id = aws_route_table.rt_c.id
    destination_cidr_block = "10.20.10.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}


resource "aws_eip" "eip-c" {
    vpc = true
    tags = {
        Name = "eip-net-prd-an2-c"
    }
}

resource "aws_nat_gateway" "ngw-c" {
    # EIP ID
    allocation_id = aws_eip.eip-c.id
    connectivity_type = "public"
    subnet_id = aws_subnet.sbn-c.id
    tags = {
        Name = "ngw-net-prd-an2-cidr"
    }    
}

###########################
# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
    description = "Transit Gateway"

    amazon_side_asn = 64512
    # auto_accept_shared_attachments = ""

    # TGW에 Default Routing Talbe 할당
    default_route_table_association = "disable"
    default_route_table_propagation = "disable"

    # DNS Support
    dns_support = "enable"
    # 
    vpn_ecmp_support = "enable"

    tags = {
        Name = "tgw-net-an2"
    }    
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attch" {
    subnet_ids         = [aws_subnet.sbn-a.id, aws_subnet.sbn-c.id]
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_id             = aws_vpc.vpc.id

    dns_support = "enable"
    ipv6_support = "disable"

    # 
    transit_gateway_default_route_table_association = "false"
    transit_gateway_default_route_table_propagation = "false"

    tags = {
        Name = "tgw-attach-net-an2"
    }    
}

### VPC 연결 1개당 Routing Table 1개 필요
resource "aws_ec2_transit_gateway_route_table" "tgw-rt" {
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id

    tags = {
        Name = "tgw-rt-net-an2"
    }    
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_assoc" {
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_propa" {
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id
}


resource "aws_ec2_transit_gateway_route" "tgw-rt-rule" {
    destination_cidr_block         = "10.20.0.0/24"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id 
}

resource "aws_ec2_transit_gateway_route" "tgw-rt-rule0" {
    destination_cidr_block         = "0.0.0.0/0"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id 
}



#########################
# Security Group

resource "aws_security_group" "sg_pub" {
    name        = "secgrp-net-prd-an2"
    description = "Allow 80, 22, ICMP inbound traffic"
    vpc_id      = aws_vpc.vpc.id

    /*
    ingress = [
        {
            description      = "For HTTP"
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = [""]
            security_groups = []
            self = "true"            
        },
        {
            description      = "For SSH"
            from_port        = 22
            to_port          = 22
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = "true"            
        }
    ]

    egress = [
        {
            description = "Allow all outputbound"
            from_port        = 0
            to_port          = 0
            protocol         = "-1"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            
            prefix_list_ids = [""]
            security_groups = [""]
            self = "true"
        }
    ]
    */
    tags = {
        Name = "sg-net-prd-an2"
    }
}

resource "aws_security_group_rule" "sg_http" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_pub.id
}

resource "aws_security_group_rule" "sg_https" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_pub.id
}

resource "aws_security_group_rule" "sg_ssh" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.sg_pub.id
}

resource "aws_security_group_rule" "sg_outbound" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.sg_pub.id
}