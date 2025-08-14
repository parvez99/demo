terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket  = "pmulani-prod-tf-backend"
    key     = "state/pmulani-prod-eks-eu-west-1-tf-backend.tfstate"
    region  = "eu-west-1"
    encrypt = true
    profile = "kpersonal"
  }
}