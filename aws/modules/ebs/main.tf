# EBS

####################
# EBS Volume
resource "aws_ebs_volume" "ebs_proj_an2_a" {
    availability_zone = "ap-northeast-2a"

    # EBS Type
    ## standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp2)
    type = "gp2"

    # size or snapshot_id (required)
    # Size in GiB
    size              = 40
    ## snapshot_id = 

    # Type 별 Option
    ## io1, io2 or gp3 경우
    ## iops = 

    ## gp3인 경우
    ## throughput =


    # 암호화
    ## encrypted = "true"
    ## kms_key_id = ""


    tags = {
        Name = "HelloWorld"
    }
}


####################
# EBS Snapshot
resource "aws_ebs_snapshot" "ebs_snap_proj_an2" {
    volume_id = aws_ebs_volume.example.id
    description = ""

    tags = {
        Name = "ebs_snap_proj_an2"
    }
}

