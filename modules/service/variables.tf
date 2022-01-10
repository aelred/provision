variable name {
  type = string
}

variable image {
  type = string
  default = null
}

variable flux_namespace {
  type = string
  default = "flux-system"
}

variable manifests_repository {
  type    = string
  default = "manifests"
}

variable manifests_main_branch {
  type    = string
  default = "main"
}