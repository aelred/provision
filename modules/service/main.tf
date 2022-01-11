module github_webhook {
  source = "../flux_github_webhook"
  name   = var.name
  receiver = "${var.name}-github"
  repository = var.name
  flux_namespace = var.flux_namespace
}

module dockerhub_webhook {
  source = "../flux_webhook"
  name = "dockerhub-${var.name}"
  receiver = "${var.name}-dockerhub"
  flux_namespace = var.flux_namespace
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

locals {
  image = coalesce(var.image, var.name)
}

moved {
  from = github_repository_webhook.webhook
  to = module.github_webhook.github_repository_webhook.webhook
}

moved {
  from = kubernetes_secret.webhook_token
  to = module.github_webhook.kubernetes_secret.webhook_token
}

moved {
  from = random_password.webhook_token
  to = module.github_webhook.random_password.webhook_token
}

output go_here_and_add_webhook_url {
  value = "https://hub.docker.com/repository/docker/aelred/${local.image}/webhooks"
}

output dockerhub_webhook_url {
  value = module.dockerhub_webhook.webhook_url
}