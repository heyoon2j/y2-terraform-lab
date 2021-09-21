## Config Instance AMI 
resource "aws_ami" "ami_proj_an2_0" {

    name = "ami-proj-an2-0"
    description = "AMI for Project's Auto Scaling"

    root_device_name = ""
    virtualization_type = ""

    tags = {
        Name = "ami-proj-an2-0"
    }
}


## Coyp EC2 Instance
resource "aws_ami_from_instance" "ami_proj_an2_1" {
    name = "ami-proj-an2-1"

    # Instance ID
    source_instance_id = ""

    #  일관성 없는 파일 시스템 상태의 스냅샷을 유발할 수 있음
    snapshot_without_reboot = "false"

    tags = {
        Name = "ami-proj-an2-1"
    }
}

## Other Account's AMI Permission
resource "aws_ami_launch_permission" "ami_luanch_permit_proj_an2" {
    image_id   = ""
    account_id = ""
}

