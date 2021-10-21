terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>3.58.0"
            configuration_aliases = [ aws.webService, aws.webService_test ]
        }
    }
}