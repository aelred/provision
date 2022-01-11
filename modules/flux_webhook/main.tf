resource kubernetes_secret webhook_token {
  metadata {
    name = "${var.name}-webhook-token"
    namespace = var.flux_namespace
  }

  data = {
    token = random_password.webhook_token.result
  }
}

resource "random_password" "webhook_token" {
  length = 40
}

locals {
  webhook_sha = sha256("${random_password.webhook_token.result}${var.receiver}${var.flux_namespace}")
}

output webhook_url {
  value = "https://flux-webhook.ael.red/hook/${local.webhook_sha}"
}

output webhook_token {
  value = random_password.webhook_token.result
  sensitive = true
}