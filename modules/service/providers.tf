terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
  }
}
