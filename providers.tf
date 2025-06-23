provider "aws" {
  region = "eu-west-1b"
}

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "random" {
  # Configuration options
}