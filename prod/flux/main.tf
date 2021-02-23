locals {
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
  github_owner = data.github_user.me.login
}

resource tls_private_key main {
  algorithm = "RSA"
  rsa_bits  = 4096
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
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
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

data github_user me {
  username = ""
}