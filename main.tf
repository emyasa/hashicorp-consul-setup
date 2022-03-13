terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
}

data "aws_availability_zones" "available" {
    state = "available"
    filter {
        name = "group-name"
        values = [var.aws_default_region]
    }
}
