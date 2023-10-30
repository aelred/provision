resource "hcloud_server" "kube" {
  name        = "kube"
  server_type = "cpx11"
  image       = "ubuntu-22.04"
  user_data = templatefile("kube/cloud-init.yml", { fully_qualified_domain_name = "kube.${var.domain}" })
  ssh_keys = [hcloud_ssh_key.key.id]
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.zone.id
  name    = "*"
  type    = "A"
  ttl     = "300"
  records = [hcloud_server.kube.ipv4_address]
}