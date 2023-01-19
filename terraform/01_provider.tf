terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4"
    }
  }

  backend "s3" {
    bucket = "terraclone-infra"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Name        = local.name
      Environment = local.environment
    }
  }
}

data "aws_caller_identity" "current" {}