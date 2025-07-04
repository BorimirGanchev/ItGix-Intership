terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            #pin the version if it is in production otherwise use the latest
            version = "6.2.0"
        }
    }
}