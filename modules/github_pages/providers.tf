terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.30.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.3.0"
    }
  }
}
