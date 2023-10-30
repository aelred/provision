resource "hcloud_server" "kube" {
  name        = "kube"
  server_type = "cpx11"
  image       = "ubuntu-22.04"
  user_data = templatefile("kube/cloud-init.yml", {
    fully_qualified_domain_name = "kube.${var.domain}"
    linux_device                = hcloud_volume.kube.linux_device
    mount_dir_name              = "longhorn"
  })
  ssh_keys = [hcloud_ssh_key.key.id]
}

resource "hcloud_volume" "kube" {
  name   = "kube"
  size   = 10
  format = "ext4"
}

resource "hcloud_volume_attachment" "kube" {
  volume_id = hcloud_volume.kube.id
  server_id = hcloud_server.kube.id
  automount = false
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.zone.id
  name    = "*"
  type    = "A"
  ttl     = "300"
  records = [hcloud_server.kube.ipv4_address]
}
