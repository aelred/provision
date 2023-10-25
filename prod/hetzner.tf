resource "hcloud_ssh_key" "key" {
  name       = "personal-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
