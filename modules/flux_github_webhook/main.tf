resource github_repository_webhook webhook {
  repository = var.repository
  events     = ["push"]
  configuration {
    url = module.flux_webhook.webhook_url
    secret = module.flux_webhook.webhook_token
    content_type = "form"
  }
}

module flux_webhook {
  source = "../flux_webhook"
  name   = "github-${var.name}"
  receiver = var.receiver
  flux_namespace = var.flux_namespace
}

moved {
  from = kubernetes_secret.webhook_token
  to = module.flux_webhook.kubernetes_secret.webhook_token
}

moved {
  from = random_password.webhook_token
  to = module.flux_webhook.random_password.webhook_token
}
