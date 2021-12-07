# Route 53

/*
1. Hostzone
    1) Zone 생성
    2) 
    3) 
    4) Routing Table의 Route 추가
    5) Routing Table Association
2. Record
    1) EIP 생성
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