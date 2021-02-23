module static_site {
  source  = "github.com/aelred/terraform-aws-static-site?ref=5b5d64a"
  domain = "${var.subdomain}.${var.domain}"
  index = var.index
  error_document = ""
  allowed_origins = ["*"]
  secret = "adiosjaoidjwoijdij"
}

resource github_actions_secret aws_access_key_id {
  repository = var.repository
  secret_name = "AWS_ACCESS_KEY_ID"
  plaintext_value = module.static_site.deploy-id
}

resource github_actions_secret aws_secret_access_key {
  repository = var.repository
  secret_name = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = module.static_site.deploy-secret
}

resource github_actions_secret aws_region {
  repository = var.repository
  secret_name = "AWS_REGION"
  plaintext_value = data.aws_region.current.name
}

resource github_actions_secret bucket {
  repository = var.repository
  secret_name = "STATIC_SITE_BUCKET"
  plaintext_value = module.static_site.bucket-name
}

data aws_region current { }