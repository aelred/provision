variable flux_namespace {
  type = string
}

variable manifests_repository {
  type    = string
  default = "manifests"
}

variable manifests_main_branch {
  type    = string
  default = "main"
}

variable manifests_target_path {
  type    = string
  default = ""
}

variable manifests_additional_resources {
  type = map(string)
  default = {}
}

variable github_token {
  type = string
}