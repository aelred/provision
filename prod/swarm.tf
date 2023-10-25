resource "hcloud_server" "drone" {
  name        = "drone"
  server_type = "cpx11"
  image       = "ubuntu-22.04"
  user_data = templatefile("cloud-init.yml", { fully_qualified_domain_name = "drone.${var.domain}" })
  ssh_keys = [hcloud_ssh_key.key.id]

  # Backups and delete protection cus "important" data is persisted in this server (e.g. certificates, Tetris highscores...)
  # Another option is to add volumes and connect them to Docker Swarm using CSI:
  # https://github.com/hetznercloud/csi-driver/blob/main/docs/docker-swarm/README.md
  # Each volume is minimum 10GB - so I'd need to awkwardly share them or accept the waste
  backups            = true
  delete_protection  = true
  rebuild_protection = true
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.zone.id
  name    = "*"
  type    = "A"
  ttl     = "300"
  records = [hcloud_server.drone.ipv4_address]
}