module s3_site {
  source = "../../modules/s3_site"
  repository = "cv.ael.red"
  domain = var.domain
  subdomain = "cv"
  index = "tech.pdf"
}
