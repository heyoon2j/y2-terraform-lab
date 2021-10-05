/*
1. User
    1) User 생성
    2) User Policy 생성
    3) 생성한 User Policy Attachment
    4) Login Profile(Password 접속), Access Key(CLI), SSH Key

2. Group
    1) Group 생성
    2) Group Policy 설정
    3) 생성한 Group Policy Attachment
    4) Group Membership에 User 추가

3. Role
    1) Role 생성
    2) Role Policy 설정
    3) 생성한 Role Policy Attachment


*/


###### User #####

resource "aws_iam_user" "iam-u-proj-dev0" {
    name = "devUser0"
    # 일반적으로는 사용되지 않고, 조직 구조와 일치하기 위해 사용된다.
    ## "/" (Default)
    path = "/company/team/engineer/"

    # Terraform에서 관리하지 않는 access key, mfa 등 삭제할지 여부
    force_destroy = "false"

    # Policy 생성 후 Attach 할 것이기 때문에 사용하지 않는다.
    ## permissions_boundary = 

    tags = {
        Name = "iam-user-proj-dev"
    }
}

resource "aws_iam_user_login_profile" "example" {
    user    = aws_iam_user.iam-u-proj-dev0.name
    pgp_key = "${base64encode(file("iam.gpg.pubkey"))}"
    password_reset_required = "true"
}


resource "aws_iam_access_key" "lb" {
    user    = aws_iam_user.iam-u-proj-dev0.name
    pgp_key = "keybase:some_person_that_exists"
    ## Secret Key등 terraform output 명령어를 이용하여 확인
    ## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key
}


resource "aws_iam_user_policy" "iam-u-policy-proj-dev" {
    name = "test"
    user = aws_iam_user.iam-u-proj-dev0.name

    policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "ec2:Describe*"
                ],
                "Effect": "Allow",
                "Resource": "*"
            }
        ]
    }
    EOF
}

resource "aws_iam_user_policy_attachment" "test-attach" {
    user       = aws_iam_user.iam-u-proj-dev0.name
    policy_arn = aws_iam_policy.iam-u-policy-proj-dev.arn
}



##### Group #####
resource "aws_iam_group" "iam-g-proj-dev" {
    name = "developer"
    path = "/company/"
}


resource "aws_iam_group_policy" "iam-g-proj-policy" {
    name  = "my_developer_policy"
    group = aws_iam_group.iam-g-proj-dev.name

    # Terraform's "jsonencode" function converts a
    # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "ec2:Describe*",
                ]
                Effect   = "Allow"
                Resource = "*"
            },
        ]
    })
}

resource "aws_iam_group_policy_attachment" "iam-g-policy-attach-proj-dev" {
    group      = aws_iam_group.iam-g-proj-dev.name
    policy_arn = aws_iam_policy.iam-g-proj-policy.arn
}


##### Group #####
resource "aws_iam_group_membership" "iam-g-mem-proj-dev" {
    name = "iam-group-mem-proj-dev"

    users = [
        aws_iam_user.user_one.name,
        aws_iam_user.user_two.name
    ]

    group = aws_iam_group.iam-g-proj-dev.name
}



##### Role #####

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "instance" {
  name               = "instance_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}


