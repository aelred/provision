inputs = {
  domain = "ael.red"
}

generate provider {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.28.0"
    }
    github = {
      source = "integrations/github"
      version = "~> 4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.10.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = "~> 0.0.12"
    }
  }
}

provider aws {
  region = "eu-west-2"
}

provider github {}

provider flux {}

provider kubectl {}

provider kubernetes {
  config_path = "~/.kube/config"
}
EOF
}
