# RDS
1. DB Subnet Group: DB Instance의 가용 Subnet
2. DB Instance : DB 생성
3. DB Parameter Group : Log를 위한 파라미터 그룹을 생성하여 연결
4. 


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

    # Datbase Name
    name                 = "mydb"
    username             = "foo"
    password             = "foobarbaz"
    option_group_name    = ""
    parameter_group_name = "default.mysql5.7"

    # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
    engine               = "aurora-postgresql"
    engine_version       = "11.9"


    ##### DB Instance
    instance_class       = "db.t3.micro"


    ##### Storage (Aurora의 경우 자동 확장)
    # Storage Type
    ## storage_type = "io1"



    # 기본 스토리지 (GiB)
    ## allocated_storage    = 10
    
    # Storage Autoscaling (GiB)
    ## max_allocated_storage = 0

    # IOPS
    ## iops = 

    
    ##### Network
    ## Master DB Instance AZ
    availability_zone = "ap-northeast-2a"
    ## 사용할 Subnet Group
    db_subnet_group_name = ""

    # Port Number
    port = 5432

    # Public Access
    publicly_accessible = "false"

    # Security Group
    vpc_security_group_ids = [""]



    ##### HA
    # 다중 AZ 여부
    multi_az = "false"

    # 해당 DB를 Replica로 할지 여부
    ## 해당 옵션을 삭제하면 완전히 독립형 데이터베이스로 승격된다.
    replicate_source_db = aws_db_instance.test.arn



    ##### Backup 
    # Backup할 기간 / 0 ~ 35
    backup_retention_period = 0
    # 자동 백업 활성화 시, 일일 시간 범위(UTC) / ex "09:46-10:16"
    ## backup_window = ""

    # DB 인스턴스가 삭제된 직후, 자동으로 백업을 제거할지 여부 지정
    delete_automated_backups = "true"

    # DB Instance가 삭제되기 전에 최종 DB 스냅샷 생성을 스킵할지 여부
    skip_final_snapshot  = "true"



    ##### Restoring
    # 스냅샷에서 이 데이터베이스를 생성할지 여부
    ## snapshot_identifier = "rds:production-2015-06-26-06-05"

    # 특정 지점으로 복구
    ## restore_to_point_in_time = {}

    ##### Migration or 새로운거 만들 때
    ## S3에서 스냅샷 가지고 오기 (새 인스턴스만 가능)
    ## s3_import {}


    ##### Maintenance
    # 변경 사항 즉시 적용여부
    apply_immediately = "false"

    # Version Upgrade, 비동기식으로 업그레이드 진행
    allow_major_version_upgrade = "false"
    auto_minor_version_upgrade = "true"

    # Maintenance window
    maintenance_window = "ddd:hh24:mi-ddd:hh24:mi"


    ##### Log
    # Engine 마다 다르므로 확인 필요    
    enabled_cloudwatch_logs_exports = [""]


    ##### Security
    # CA 인증
    # ca_cert_identifier = 

    # KMS
    kms_key_id = ""

    # Storage 암호화
    storage_encrypted = "true"



    ##### Option
    # Enhanced Monitoring
    ## 0이면 확장 모니터링 비활성화
    ## 0, 1, 5, 10, 15, 30, 60
    monitoring_interval = 0
    # Cloudwatch에 대한 Role이 필요
    # monitoring_role_arn = ""


    # Performance Insights: 성능 개선 도우미
    performance_insights_enabled = "false"
    ## performance_insights_kms_key_id = ""
    # 데이터 보관 : 7(일) / 731(2년)
    ## performance_insights_retention_period = 7




    # 삭제 방지 기능 활성 여부
    deletion_protection = "false"

    # 모든 인스턴스 tags를 스냅샷에 복사한다.
    copy_tags_to_snapshot = "false"

    tags = {
        Name = "rds_proj-an2"
    }


}



####################
# DB Parameter Group
resource "aws_db_parameter_group" "rds_parm_group_an2" {
    name   = "rds-pg"
    family = "mysql5.6"
    description = ""

    parameter {
        name  = "character_set_server"
        value = "utf8"
        # 파라미터 적용 시점
        ## "immediate" (default) or "pending-reboot"
        ## 일부 엔진은 재부팅 없이 일부 매개변수를 적용할 수 없다.
        ## 이때에 "pending-reboot"를 사용해야 한다.
        apply_method = "immediate"
    }

    parameter {
        name  = "character_set_client"
        value = "utf8"
    }
}



####################
# DB Option Group



