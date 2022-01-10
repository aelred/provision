locals {
  # taken directly from the registry: https://registry.terraform.io/providers/fluxcd/flux/latest/docs/guides/github
  # don't totally understand what it is, but it's not secret and it's got nothing to do with my machine
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  github_owner = data.github_user.me.login
}


resource tls_private_key main {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data flux_install main {
  target_path = var.manifests_target_path
  components = [
    "source-controller",
    "kustomize-controller",
    "helm-controller",
    "notification-controller",
    "image-reflector-controller",
    "image-automation-controller"
  ]
}

data flux_sync main {
  target_path = var.manifests_target_path
  url         = "ssh://git@github.com/${local.github_owner}/${var.manifests_repository}.git"
  branch      = var.manifests_main_branch
  namespace   = var.flux_namespace
}

resource kubernetes_namespace flux_system {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data kubectl_file_documents install {
  content = data.flux_install.main.content
}

data kubectl_file_documents sync {
  content = data.flux_sync.main.content
}

locals {
  install = [ for v in data.kubectl_file_documents.install.documents : {
    data: yamldecode(v)
    content: v
  }
  ]
  sync = [ for v in data.kubectl_file_documents.sync.documents : {
    data: yamldecode(v)
    content: v
  }
  ]
}

resource kubectl_manifest install {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}

resource kubectl_manifest sync {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}

resource kubernetes_secret main {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.name
    namespace = var.flux_namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource kubernetes_secret github_token {
  metadata {
    name = "github-token"
    namespace = var.flux_namespace
  }

  data = {
    token = var.github_token
  }
}

# GitHub
resource github_repository main {
  name = var.manifests_repository
  auto_init = true
}

resource github_branch_default main {
  repository = github_repository.main.name
  branch     = var.manifests_main_branch
}

resource github_repository_deploy_key main {
  title      = "staging-cluster"
  repository = github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = false
}

resource github_repository_file install {
  repository = github_repository.main.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = var.manifests_main_branch
}

resource github_repository_file sync {
  repository = github_repository.main.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = var.manifests_main_branch
}

resource github_repository_file kustomize {
  repository = github_repository.main.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = var.manifests_main_branch
}

resource github_repository_file resource {
  for_each = var.manifests_additional_resources
  repository = github_repository.main.name
  content = each.value
  file = each.key
  branch = var.manifests_main_branch
}

module github_webhook {
  source = "../../modules/flux_github_webhook"
  name   = "manifests"
  receiver = var.flux_namespace
  repository = "manifests"
}

data github_user me {
  username = ""
}
