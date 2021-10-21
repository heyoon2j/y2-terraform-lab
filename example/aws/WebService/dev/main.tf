provider "aws" {
    alias = "webService"
    region = "ap-northeast-2"
}

provider "aws" {
    alias = "webService_test"
    region = "ap-northeast-2"
}

locals {
    azs = ["ap-northeast-2a", "ap-northeast-2c"]
}


module "vpc" {
    source = "./modules/vpc"
    providers = {
        aws = aws.webService
    }

    # Variable
    azs = local.azs

}
/*
module "ec2" {
    source = "./modules/ec2"
    providers = {
        aws = aws.webService
    }

    vpc_id = 
    sbn_id = 
    sg_id = 
}
*/