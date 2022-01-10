module github_webhook {
  source = "../flux_github_webhook"
  name   = var.name
  receiver = "${var.name}-github"
  repository = var.name
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
