# Route 53

/*
1. Hostzone
    1) Hosting Zone 생성
    2) Domain 생성 및 Name Server 등록 (AWS 뿐만 아니라 다른 DNS 대행 업체 이용 가능)
    3) Record 생성
2. VPC
    1) DHCP 옵션 세트 생성
    2) NAT Gateway 생성
    2) Routing Table의 Route 추가
3. IGW Gateway
    1) IGW Gateway 생성


*/

resource "aws_route53_zone" "zone_proj_y2jtest" {
    name = "y2jtest.com"
    # Comment로 같은 이름의 Hostzone을 분리할 수 있다.
    comment = ""

}