terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">=2.20.0"
    }
  }
}
