output "vpc_id" {
    value = aws_vpc.vpc-y2net-prd-an2.id
    description = "VPC ID"
}

output "pubSub_id" {
    description = "Public Subnet ID"
    value = aws_subnet.sbn-y2net-prd-an2-a-pub.id
}

/*
output "priSub_id" {
    description = "Private Subnet ID"
    value = aws_subnet.sbn-y2net-prd-an2-a-pri.id
}
*/
/*
output "sg_id" {
    description = "Security Group LIst"
    value = aws_security_group.sg_pub.id
}
*/