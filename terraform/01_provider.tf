provider "aws" {
  region = var.region
}

terraform {
    backend "s3" {
        bucket = "django-ecs-terraform"
        key    = "state.tfstate"
        region = "us-west-1"
    }
}