/*
1. VPC
    1) VPC 생성
    2) Subnet 생성
    3) Routing Table 생성
    4) Routing Table의 Route 추가
    5) Routing Table Association
2. NAT Gateway
    1) EIP 생성
    2) NAT Gateway 생성
    2) Routing Table의 Route 추가
3. IGW Gateway
    1) IGW Gateway 생성
    2) Routing Table의 Route 추가
4. Transit Gateway
    1) Transit Gateway 생성
    2) Transit Gateway의 Routing Table 생성
    3) Attachement 생성 (어떤, 무엇을, 어떻게 연결을 할 것인지 등의 정보가 저장)
    4) Attachment를 Transit Gateway의 Routing Table에 Association
    5) Attachment를 Transit Gateway의 Routing Table에 Propagation
    6) Transit Gateway Routing 추가 작업
*/

locals {
    ## Subnet
    sbns = {
        name = [
            "sbn-y2net-prd-an2-a-pub",
            "sbn-y2net-prd-an2-c-pub",
            "sbn-y2net-prd-an2-a-pri",
            "sbn-y2net-prd-an2-c-pri"
        ]
        cidr = cidrsubnets(locals.vpc["cidr"], 2, 2, 2, 2)
    }


    ## Gateway
    ## Internet Gateway
    igw = {
        name = "igw-y2net-prd-an2"
    }

    ## NAT Gateway
    ngw = {
        name = "nat-y2net-prd-an2"
    }

    ## Transit Gateway
    tgw = {
        name = "tgw-y2net-prd-an2"
        # id = aws_ec2_transit_gateway.tgw-y2net-prd-an2.id
    }

    ## EIP
    eipNat = {
        name = "eip-nat-y2net-prd-an2"
        # id = aws_eip.eip-nat-y2net-prd-an2.id
    }

    ## Routing Table
    pubSubRT = {
        name = "rt-y2net-prd-an2-a-pub"
        # id = aws_route_table.rt-y2net-prd-an2-a-pub.id
    }

    priSubRT = {
        name = "rt-y2net-prd-an2-a-pri"
    }
}


##### VPC #####
resource "aws_vpc" "vpc-y2net" {

    cidr_block = "10.20.0.0/24"

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
        Name : "vpc-y2net-prd-an2"
    }
}

##### Subnet #####
resource "aws_subnet" "sbn-y2net" {
    count = 

}

resource "aws_subnet" "sbn-y2net-prd-an2-a-pub" {

    vpc_id = aws_vpc.vpc-y2net-prd-an2.id # local.vpc["id"]
    cidr_block = local.pubSub["cidr"]

    availability_zone = var.azs[0]
    assign_ipv6_address_on_creation = "false"

    tags={
        Name : local.pubSub["name"]
    }
}


resource "aws_subnet" "sbn-y2net-prd-an2-a-pri" {

    vpc_id = aws_vpc.vpc-y2net-prd-an2.id # local.vpc["id"]
    cidr_block = local.priSub["cidr"]

    availability_zone = var.azs[0]
    assign_ipv6_address_on_creation = "false"

    tags={
        Name : local.priSub["name"]
    }
}


##### Internet Gateway #####
resource "aws_internet_gateway" "igw-y2net-prd-an2" {
    vpc_id = aws_vpc.vpc-y2net-prd-an2.id # local.vpc["id"]

    tags = {
        Name = local.igw["name"]
    }
}

##### NAT Gateway #####
resource "aws_eip" "eip-nat-y2net-prd-an2" {
    vpc = true
    tags = {
        Name = local.eipNat["name"]
    }
}

resource "aws_nat_gateway" "nat-y2net-prd-an2" {

    # EIP ID
    ## connectivity_type이 "public"인 경우에만 적용
    allocation_id = aws_eip.eip-nat-y2net-prd-an2.id # local.eipNat["id"]

    # 게이트웨이 유형
    ## "private" / "public" (Default)
    connectivity_type = "public"

    subnet_id = aws_subnet.sbn-y2net-prd-an2-a-pri.id # local.pubSub["id"]
    
    tags = {
        Name = local.ngw["name"]
    }    
}

##### Transit Gateway #####
resource "aws_ec2_transit_gateway" "tgw-y2net-prd-an2" {
    description = "Transit Gateway"

    amazon_side_asn = 64512
    ## 연결된 교차 계정 연결을 자동으로 수락할지 여부
    # auto_accept_shared_attachments = ""

    # TGW에 Default Routing Table 할당
    default_route_table_association = "disable"
    default_route_table_propagation = "disable"

    # DNS Support
    dns_support = "enable"
    # 
    vpn_ecmp_support = "enable"

    tags = {
        Name = local.tgw["name"]
    }    
}


resource "aws_ec2_transit_gateway_route_table" "tgw-rt-y2net-prd-an2" {
    transit_gateway_id = aws_ec2_transit_gateway.tgw-y2net-prd-an2.id

    tags = {
        Name = "tgw-y2net-prd-an2"
    }    
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attach-y2net-prd-an2" {
    subnet_ids         = ["${aws_subnet.sbn-y2net-prd-an2-a-pri.id}"]
    transit_gateway_id = aws_ec2_transit_gateway.tgw-y2net-prd-an2.id # local.tgw["id"]
    vpc_id             = aws_vpc.vpc-y2net-prd-an2.id # local.vpc["id"]

    dns_support = "enable"
    ipv6_support = "disable"

    # VPC 연결이 EC2 Transit Gateway의 기본 라우팅 테이블과 연결되어야 하는지
    ## Association은 Routing Table과 Attachement를 연결하기 위해 사용 (Attachment는 하나의 Routing Table에만 연결 가능)
    transit_gateway_default_route_table_association = "false"
    ## Propagation은 Routing 정보를 전파하기 위해 사용 (Attachment는 다수의 Tating Table 연결 가능)
    transit_gateway_default_route_table_propagation = "false"

    tags = {
        Name = "tgw-attach-y2net-prd-an2"
    }    
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-assoc-y2net-prd-an2" {
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-y2net-prd-an2.id
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-attach-y2net-prd-an2.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prop-y2net-prd-an2" {
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-y2net-prd-an2.id
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-attach-y2net-prd-an2.id
}

resource "aws_ec2_transit_gateway_route" "tgw-rt-rule0" {
    destination_cidr_block         = "0.0.0.0/0"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-attach-y2net-prd-an2.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt-y2net-prd-an2.id
}

/*
resource "aws_ec2_transit_gateway_route" "tgw-rt-rule" {
    destination_cidr_block         = "10.20.0.0/24"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attch.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-rt.id 
}
*/





##### Routing Table #####
resource "aws_route_table" "rt-y2net-prd-an2-a-pub" {
    vpc_id = aws_vpc.vpc-y2net-prd-an2.id # local.vpc_id

    tags = {
        Name = local.pubSubRT["name"]
    }
    /*
    depends_on = [
        aws_internet_gateway.igw
    ]
    */
}

## Association 할 때, 기본적으로 local에 대한 Routing은 자동으로 추가된다.
resource "aws_route_table_association" "rt-assoc-y2net-prd-an2-a-pub" {
    subnet_id = aws_subnet.sbn-y2net-prd-an2-a-pub.id # local.pubSub_id
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pub.id # local.pubSubRT_id
}

resource "aws_route" "rt-route-y2net-prd-an2-a-pub-igw" {
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pub.id # local.pubSubRT_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-y2net-prd-an2.id
}

resource "aws_route" "rt-route-y2net-prd-an2-a-pub-tgw-devVpc" {
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pub.id # local.pubSubRT_id
    destination_cidr_block = "10.20.10.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-y2net-prd-an2.id
}

resource "aws_route" "rt-route-y2net-prd-an2-a-pub-tgw-prdVpc" {
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pub.id # local.pubSubRT_id
    destination_cidr_block = "10.20.20.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.tgw-y2net-prd-an2.id
}


resource "aws_route_table" "rt-y2net-prd-an2-a-pri" {
    vpc_id = aws_vpc.vpc-y2net-prd-an2.id # local.vpc_id

    tags = {
        Name = local.priSubRT["name"]
    }
    /*
    depends_on = [
        aws_internet_gateway.igw
    ]
    */
}

## Association 할 때, 기본적으로 local에 대한 Routing은 자동으로 추가된다.
resource "aws_route_table_association" "rt-assoc-y2net-prd-an2-a-pri" {
    subnet_id = aws_subnet.sbn-y2net-prd-an2-a-pri.id # local.pubSub_id
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pri.id # local.pubSubRT_id
}

resource "aws_route" "rt-route-y2net-prd-an2-a-pri-nat" {
    route_table_id = aws_route_table.rt-y2net-prd-an2-a-pri.id # local.pubSubRT_id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-y2net-prd-an2.id
}
