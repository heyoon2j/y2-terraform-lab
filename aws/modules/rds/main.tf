# RDS
1. DB Subnet Group: DB Instance의 가용 Subnet
2. DB Instance : DB 생성



####################
# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_proj_an2" {
    name       = "db_subnet_proj_an2"
    subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]

    tags = {
        Name = "db_subnet_proj_an2"
    }
}



####################
# DB Instance
resource "aws_db_instance" "rds_proj_an2" {
    
    engine               = "mysql"
    engine_version       = "5.7"

    instance_class       = "db.t3.micro"
    name                 = "mydb"
    username             = "foo"
    password             = "foobarbaz"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true


    # Version Upgrade, 비동기식으로 업그레이드 진행
    allow_major_version_upgrade = "false"
    auto_minor_version_upgrade = "true"
    
    ##### Network
    ## Master DB Instance AZ
    availability_zone = "ap-northeast-2a"
    ## 사용할 Subnet Group
    db_subnet_group_name = ""


    


    # 변경 사항 즉시 적용여부
    apply_immediately = "false"


    ##### Storage
    # 기본 스토리지 (GiB)
    allocated_storage    = 10
    
    # Storage Autoscaling (GiB)
    ## max_allocated_storage = 20





    # Backup / 0 ~ 35
    backup_retention_period = 0




}



####################
# DB Subnet Group




####################
# DB Subnet Group





####################
# DB Subnet Group
