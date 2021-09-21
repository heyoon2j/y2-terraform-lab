# AutoScaling
## Order
    1) Launch Template(권장) or Launch Configuration
    2) Auto Scaling Group
        * Auto Scaling 구성
        * Scaling Policy
        * Schedule
        * Lifecycle
        * Alarm Notification
        * Attachment

##########
# Launch Template (권장)
resource "aws_launch_template" "as_tmp_proj_an2" {
    name = "as_tmp_proj_an2"
    image_id = "ami-example"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["sg-12345678"]
    key_name = "test"

    # network_interfaces {
    #    associate_public_ip_address = "false"
    #    delete_on_termination = "false"
    #}

    # iam_instance_profile {}

    instance_initiated_shutdown_behavior = "terminate"
    disable_api_termination = "false"

    # 구매 옵션
    # instance_market_options { market_type = "spot" }
    
    # ram_disk_id = "test"
    # kernel_id = "test"
    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            delete_on_termination = "true"
            volume_type="gp2"
            # size: GiB
            volume_size=8
            # iops = 
            # throughput

            # Security
            # encrypted = "false"
            # kms_key_id = ""
        }
    }

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    cpu_options {
        core_count       = 4
        threads_per_core = 2
    }

    # credit_specification {}
    # placement {}
    # ebs_optimized = true
    # elastic_gpu_specifications {}
    # elastic_inference_accelerator {}
    # license_specification {}

    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
    }

    # Detail Monitoring
    monitoring {
        enabled = "false"
    }

    user_data = filebase64("${path.module}/example.sh")

    # 생성될때 Resource에 적용되는 Tag
    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "test"
        }
    }

    tags = {
        Name = "as_tmp_proj_an2"
    }
}


#########################################################
# Auto Scaling Group & Attachment
# Auto Scaling Group
resource "aws_autoscaling_group" "asg_proj_an2" {
    name                      = "asg_proj_an2"
    max_size                  = 6
    min_size                  = 2
    desired_capacity          = 2
    vpc_zone_identifier       = [aws_subnet.example1.id, aws_subnet.example2.id]

    # Scale 활동 후 다시 활동할 대기 시간 (Second) == Warm-up time
    ## default_cooldown : Policy에서 적용

    # Using One of launch_configuration / launch_template / mixed_instances_policy
    # launch_configuration      = aws_launch_configuration.example.name
    # mixed_instances_policy    = 인터넷에서 확인
    launch_template           = ""

    # Spot Instance 사용하는 경우
    # 용량 재조정: Spot Instance가 종료되기 전에 미리 새 Instance를 준비 
    ## 목표 용량을 유지하려면 true, 일회성인 경우 false인데 여기서는 Auto Scaling으로 조정 작업을 하므로 일회성이 되지는 않는다. 
    ## capacity_rebalance = "true"
    /*
    mixed_instances_policy {
        instances_distribution {
            # 온디맨드 기본 용량
            on_demand_base_capacity                  = 0
            # 온디맨드 기본 용량을 초과한 경우, 온디맨드와 스팟 인스턴스 비율 (온디맨드 비율)
            on_demand_percentage_above_base_capacity = 60
            # 스팟 할당 전략: "capacity-optimized"(권장), "lowest-price"(기본)
            spot_allocation_strategy                 = "capacity-optimized"
            # 가용영역 당 스팟 풀의 수
            spot_instance_pools = 2
            # 스팟 인스턴스에 대한 시간당 최고 가격(입찰가)
            ## spot_max_price = ""
        }

        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.example.id
                # Template version : Version Number / $Latest / $Default(Default)
                version = "$Default"
            }

            override {
                instance_type     = "c4.large"
                ## launch_template_specification {}
                # 목표 용량 % 가중치
                ## 여기서의 가중치는 해당 인스턴스가 용량에서 차지하는 가중치로
                ## 의미는 용량 / 가중치 = 인스턴스 개수
                weighted_capacity = "3"
            }

            override {
                instance_type     = "c3.large"
                weighted_capacity = "2"
            }
        }
    }
    */
 
    # Health Check 유예 기간(Default: 300 Second)
    ## Script가 전부 실행되었다고, 바로 트래픽을 수신되지 않는 경우도 있다.
    ## 서비스의 초기 준비시간이 필요한 경우 등의 이유
    health_check_grace_period = 300

    # Health Check "EC2" / "ELB"
    ## EC2인 경우, running/impared를 제외한 상태인 경우 비정상으로 간주
    ## ALB인 경우, ALB가 healthy/unhealthy(HTTP)로 구분
    health_check_type         = "ELB"


    # Detail Monitoring
    ## enabled_metrics = [""]    // 사용할 지표들 확인
    ## metrics_granularity = "1Minute"


    # 종료 방법 정책
    termination_policies = ["Default", "AllocationStrategy", "OldestLaunchTemplate", "ClosestToNextInstanceHour", "OldestInstance"]
    # 일시 중단할 프로세스 목록 (안 사용될 거 같다)
    ## suspended_processes = [""]


    # Auto Scaling Group을 파괴하는데 기다리는 시간 (Default: "10m")
    timeouts {
        delete = "15m"
    }


    # Option
    # Pool의 모든 인스턴스가 종료될때까지 기다리지 않고 Auto Scaling 삭제
    ## force_delete              = "false"
    # Placement Group
    ## placement_group           = aws_placement_group.test.id

    # Instance의 Update 및 AMI를 교체할 때 사용 (Consol 이나 CLI를 사용하는 것이 좋아보인다.)
    /*
    instance_refresh = {
        strategy = "Rolling"
        preferences {
            # 항상 유지할 최소 정상 비율 (Default: 90)
            # 100%로 설정하면 교체 비율이 한 번에 하나의 인스턴스로 제한되며, 0%로 설정하면 모든 인스턴스가 동시에 교체된다.
            min_healthy_percentage = 50

            # Warm-up Time (Second)
            instance_warmup = 
        }
        triggers = ["launch_template"]
    }
    */

    # Auto Scaling Group에 Warm Pool 추가
    /*
    warm_pool = {
        pool_state = "Stopped"  // "Stopped"(Default) or "Running"
        min_size = 0 // 0 (Default)
        max_group_prepared_capacity = // Terminated 상태를 제외하고 Warm Pool 안에 있는 인스턴스 최대 수
    }
    */

    # Terraform
    ## Terraform이 ASG 인스턴스가 정상 상태가 될때까지 기다려야 하는 최대 시간
    ## 기본 값: "10m"
    ## wait_for_capacity_timeout = "10m"


    tag {
        key                 = "foo"
        value               = "bar"
        # EC2 인스턴스로 태그 전파
        propagate_at_launch = true
    }

    tag {
        key                 = "lorem"
        value               = "ipsum"
        propagate_at_launch = false
    }

    tag {
        key                 = "Name"
        value               = "asg_proj_an2"
        propagate_at_launch = false
    }
}


##### Auto Scaling Policy
resource "aws_autoscaling_policy" "as_policy_proj_an2" {
    name = "as_conf_proj_an2"
    autoscaling_group_name = "name"

    # 정책 유형 
    ## "SimpleScaling"(Default)/"StepScaling"/"TargetTrackingScaling"/"PredictiveScaling"
    policy_type = "TargetTrackingScaling"

    # "TargetTrackingScaling" 사용하는 경우
    ## Configruation
    target_tracking_configuration = {
        # 기존에 제공하는 Metric을 사용하는 경우: ASGAverageCPUUtilization, ASGAverageNetworkIn, ASGAverageNetworkOut, LBRequestCountPerTarget
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }

        # 이외의 사용자가 원하는 Metric을 사용하는 경우
        customized_metric_specification {
            # 측정 항목의 차원: https://docs.aws.amazon.com/autoscaling/plans/APIReference/API_CustomizedScalingMetricSpecification.html
            metric_dimension {
                name  = "fuga"
                value = "fuga"
            }

            metric_name = "hoge"
            namespace   = "hoge"
            # 통계
            statistic   = "Average"
        }

        # Metric 대상 값
        target_value = 40.0
    }
    
    # Warm-up Time (Default: 300 Second)
    estimated_instance_warmup = 300


    # "SimpleScaling" & "StepScaling" 사용하는 경우
    ## 용량 선택 방법 (인스턴스 단위/절대 값/백분율)
    ## "ChangeInCapacity" : 현재 용량을 지정된 값만큼 증감
    ## "ExactCapacity" : 현재 용량을 지정된 값으로 변경
    ## "PercentChangeInCapacity" : 현재 용량의 백분율만큼 증감
    # adjustment_type = "ChangeInCapacity"

    # "StepScaling" 사용하는 경우
    ## metric_aggregation_type = 
    ## step_adjustment = {}
    ## estimated_instance_warmup = 
}


##### Scheduler
resource "aws_autoscaling_schedule" "foobar" {
    scheduled_action_name  = "foobar"
    min_size               = 0
    max_size               = 1
    desired_capacity       = 0
    start_time             = "2016-12-11T18:00:00Z"
    # End Time과 Recurrence 적용은 자유
    end_time               = "2016-12-12T06:00:00Z"
    Recurrence             = "30 0 1 1,6,12 *"
    # Time Zone: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    time_zone              = "Asia/Seoul"
    autoscaling_group_name = aws_autoscaling_group.foobar.name
}


###### Auto Scaling Lifecycle
resource "aws_autoscaling_lifecycle_hook" "" {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
    {
        "foo": "bar"
    }
    EOF

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
}


##### Alarm
resource "aws_autoscaling_notification" "as_notify_proj_an2" {
    group_names = [
        aws_autoscaling_group.bar.name,
        aws_autoscaling_group.foo.name
    ]

    notifications = [
        "autoscaling:EC2_INSTANCE_LAUNCH",
        "autoscaling:EC2_INSTANCE_TERMINATE",
        "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
        "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
    ]

    topic_arn = aws_sns_topic.example.arn
}


##### Auto Scaling Attachment
resource "aws_autoscaling_attachment" "as_attach_proj_an2" {
    # ELB 선택
    ## Classic Load Balancer인 경우 ELB ID
    ## elb = 
    ## ALB의 Target Group ARN
    autoscaling_group_name = ""
}

###### Auto Scaling Tag
resource "aws_autoscaling_group_tag" "example" {
    for_each = toset(
        [for asg in flatten(
            [for resources in aws_eks_node_group.example.resources : resources.autoscaling_groups]
        ) : asg.name]
    )

    autoscaling_group_name = each.value

    tag {
       key   = "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType"
       value = "SPOT"

        propagate_at_launch = false
    }
}



############################################################

##### Launch Configuration (권장되지 않음!!!!!)
resource "aws_launch_configuration" "as_conf_proj_an2" {
    name = "as-conf-proj-an2"

    image_id = ""
    instance_type = "t2.micro"

    ## Public IP associate
    associate_public_ip_address = "false"
    
    ## IAM name
    ## iam_instance_profile = ""
    
    ## Detail Monitoring using CloudWatch
    enable_monitoring = "false"
    
    ## Tenancy
    ## placement_tenancy = "default" or "dedicated"
    
    ## Spot Instance
    ## spot_price = 

    ## Detail Option
    metadata_options {
        http_endpoint = "enabled"   # enabled, disabled
        http_put_response_hop_limit = 2
        http_tokens="optional"      # optional, required
    }
    
    ## User Data
    user_data = <<EOF
    #!/bin/bash
    sudo useradd -G wheel sysadmin -m -u 520
    sudo echo 'qwer1234!' | passwd --stdin sysadmin
    sudo echo "sysadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo rm /etc/localtime
    sudo ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
    sudo systemctl restart sshd.service > /dev/null 2>&1;
    sudo yum install -y telnet*
    EOF

    ## user_data_base64 : file like gzip

    # Add Storage
    root_block_device {
        ## Root Device
        volume_type="gp2"
        
        # size: GiB
        volume_size=8
        
        # Only valid for volume_type is io1, io2, gp3
        ## iops = ,
        # Only valid for volume_type is gp3
        ## throughput = ,
           
        delete_on_termination = "true"
        # KMS 암호화
        ## encrypted =
        ## kms_key_id =
    }
    
    ## ebs_block_device = []
    ## ebs_optimized = "true" or "false"
    
    # Security Group
    security_groups=[""]
    
    # Key Pair
    ## key_name = devopsKeyPair.key_name,

    tags = {
        Name = "as-conf-proj-an2"
    }
}