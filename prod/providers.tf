terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.30.0"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.31.1"
    }
  }
}

provider aws {
  region = "eu-west-2"
}

provider hcloud {}