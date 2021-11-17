# EFS
1. File System: EFS 설정
2. Backup: S3가 아닌 AWS Backup에서 관리
3. Mount Target: EC2에서 접근할 Target ENI 생성 (Subnet 당 1개)
4. Policy: EFS 정책
5. Access Point: Access Point 지정 (EFS 당 4개의 Directory를 생성할 수 있다)



####################
# File System
resource "aws_efs_file_system" "efs_proj_an2" {
    # 멱등성 파일 시스템 생성을 보장하기 위해 참조로 사용되는 고유 이름
    creation_token = "efs_proj_an2"

    ## One Zone 사용하는 경우
    ## availability_zone_name = "ap-northeast-2a"

    # Lifecycle
    /*
    lifecycle_policy {
        # Either transition_to_ia or transition_to_primary_storage_class
        ## "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"
        transition_to_ia = "AFTER_30_DAYS"

        transition_to_primary_storage_class = "AFTER_1_ACCESS"   
    }
    */

    # Performance Mode
    ## "maxIO" / "generalPurpose" (Default)
    performance_mode = "generalPurpose"

    # Throughput Mode
    ## "bursting" (Default) / "provisioned"
    throughput_mode = "bursting"
    
    ## 처리량 (MiB/s), "provisioned" 인 경우에만 사용
    ## provisioned_throughput_in_mibps = 

    # Security
    ## encrypted = "true"
    ## kms_key_id = "arn"


    tags = {
        Name = "efs_proj_an2"
    }
}


####################
# Backup

resource "aws_efs_backup_policy" "efs_backup_proj_an2" {
    
    file_system_id = aws_efs_file_system.fs.id

    backup_policy {
        ## ENABLED, DISABLED
        status = "DISABLED"
    }
}



####################
# Mount Target
## Subnet 당 1개

resource "aws_efs_mount_target" "efs_mt_proj_an2_a" {
    file_system_id = aws_efs_file_system.foo.id
    subnet_id      = aws_subnet.alpha.id
    security_groups = 
}

resource "aws_efs_mount_target" "efs_mt_proj_an2_a" {
    file_system_id = aws_efs_file_system.foo.id
    subnet_id      = aws_subnet.beta.id
    security_groups = 
}



####################
# Policy

resource "aws_efs_file_system_policy" "efs_policy_proj_an2" {
  file_system_id = aws_efs_file_system.fs.id

  bypass_policy_lockout_safety_check = "false"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.test.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}




####################
# Access Point

resource "aws_efs_access_point" "efs_access_proj_an2" {
    file_system_id = aws_efs_file_system.foo.id

    # 접속할 POSIX 사용자 및 그룹 id
    posix_user = {
        ## Accepts values from 0 to 4294967295
        gid = 123421
        secondary_gids = "123422,123423"

        ## 
        uid = 123421
    }
    
    # 
    root_directory = {
        # 해당 Root Directory가 없으면 해당 옵션으로 만들어줘야 한다.
        creation_info = {
            owner_gid = 
            owner_uid = 
            permissions = "0755"
        }
        path = "/efs/efs_access_proj_an2/"
    }
    tags = {
        Name = "efs_access_proj_an2"
    }
}



