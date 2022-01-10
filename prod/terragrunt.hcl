inputs = {
  domain = "ael.red"
  hcloud_ssh_key_name = "aelred717@gmail.com"
  flux_namespace = "flux-system"
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
      version = "~> 4.19.1"
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
      version = "~> 0.8.1"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.24.1"
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

provider hcloud {}
EOF
}
