resource kubernetes_secret webhook_token {
  metadata {
    name = "github-${var.name}-webhook-token"
    namespace = var.flux_namespace
  }

  data = {
    token = random_password.webhook_token.result
  }
}

resource github_repository_file kustomization {
  repository = var.manifests_repository
  file       = "services/${var.name}.yml"
  content    = templatefile(
    "${path.module}/kustomization.yml", { name = var.name, image = local.image, flux_namespace = var.flux_namespace }
  )
  lifecycle {
    ignore_changes = [content]
  }
}

resource github_repository_webhook webhook {
  repository = var.name
  events     = ["push"]
  configuration {
    url = "https://flux-webhook.ael.red/hook/${local.webhook_sha}"
    secret = random_password.webhook_token.result
    content_type = "form"
  }
}

resource "random_password" "webhook_token" {
  length = 40
}

locals {
  webhook_sha = sha256("${random_password.webhook_token.result}${var.name}-github${var.flux_namespace}")
  image = coalesce(var.image, var.name)
}
