resource kubernetes_secret webhook_token {
  metadata {
    name = "github-${var.name}-webhook-token"
    namespace = var.flux_namespace
  }

  data = {
    token = random_password.webhook_token.result
  }
}

resource github_repository_webhook webhook {
  repository = var.repository
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
  webhook_sha = sha256("${random_password.webhook_token.result}${var.receiver}${var.flux_namespace}")
}
