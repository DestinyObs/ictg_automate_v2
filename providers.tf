terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "local" {}  # Store state locally (change to S3 for remote)
}

provider "aws" {
  region = var.aws_region
}
