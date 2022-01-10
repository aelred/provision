terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 4.19.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
  }
}
