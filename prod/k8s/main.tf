module "provider" {
  source = "github.com/hobby-kube/provisioning//provider/hcloud?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  token           = var.hcloud_token
  ssh_keys        = [hcloud_ssh_key.key.name]
  location        = var.hcloud_location
  type            = var.hcloud_type
  image           = var.hcloud_image
  hosts           = var.node_count
  hostname_format = var.hostname_format
  apt_packages = ["ceph-common"]
}

resource hcloud_ssh_key key {
  name = var.hcloud_ssh_key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

# module "provider" {
#   source = "github.com/hobby-kube/provisioning//provider/scaleway?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   organization_id = var.scaleway_organization_id
#   access_key      = var.scaleway_access_key
#   secret_key      = var.scaleway_secret_key
#   zone            = var.scaleway_zone
#   type            = var.scaleway_type
#   image           = var.scaleway_image
#   hosts           = var.node_count
#   hostname_format = var.hostname_format
# }

# module "provider" {
#   source = "github.com/hobby-kube/provisioning//provider/digitalocean?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   token           = var.digitalocean_token
#   ssh_keys        = var.digitalocean_ssh_keys
#   region          = var.digitalocean_region
#   size            = var.digitalocean_size
#   image           = var.digitalocean_image
#   hosts           = var.node_count
#   hostname_format = var.hostname_format
# }

# module "provider" {
#   source = "github.com/hobby-kube/provisioning//provider/packet?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   auth_token       = var.packet_auth_token
#   project_id       = var.packet_project_id
#   billing_cycle    = var.packet_billing_cycle
#   facility         = [var.packet_facility]
#   plan             = var.packet_plan
#   operating_system = var.packet_operating_system
#   hosts            = var.node_count
#   hostname_format  = var.hostname_format
# }

# module "provider" {
#   source = "github.com/hobby-kube/provisioning//provider/vsphere?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   hosts                   = var.node_count
#   hostname_format         = var.hostname_format
#   vsphere_server          = var.vsphere_server
#   vsphere_datacenter      = var.vsphere_datacenter
#   vsphere_cluster         = var.vsphere_cluster
#   vsphere_network         = var.vsphere_network
#   vsphere_datastore       = var.vsphere_datastore
#   vsphere_vm_template     = var.vsphere_vm_template
#   vsphere_vm_linked_clone = var.vsphere_vm_linked_clone
#   vsphere_vm_num_cpus     = var.vsphere_vm_num_cpus
#   vsphere_vm_memory       = var.vsphere_vm_memory
#   vsphere_user            = var.vsphere_user
#   vsphere_password        = var.vsphere_password
# }

module "swap" {
  source = "github.com/hobby-kube/provisioning//service/swap?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  node_count  = var.node_count
  connections = module.provider.public_ips
}

//module "dns" {
//  source = "github.com/hobby-kube/provisioning//dns/cloudflare?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
//
//  node_count = var.node_count
//  email      = var.cloudflare_email
//  api_token  = var.cloudflare_api_token
//  domain     = var.domain
//  public_ips = module.provider.public_ips
//  hostnames  = module.provider.hostnames
//}

module "dns" {
  source = "./dns"

  node_count = var.node_count
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  domain     = var.domain
  public_ips = module.provider.public_ips
  hostnames  = module.provider.hostnames
}

# module "dns" {
#   source = "github.com/hobby-kube/provisioning//dns/google?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   node_count   = var.node_count
#   project      = var.google_project
#   region       = var.google_region
#   creds_file   = var.google_credentials_file
#   managed_zone = var.google_managed_zone
#   domain       = var.domain
#   public_ips   = module.provider.public_ips
#   hostnames    = module.provider.hostnames
# }

# module "dns" {
#   source     = "github.com/hobby-kube/provisioning//dns/digitalocean?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"
#
#   node_count = var.node_count
#   token      = var.digitalocean_token
#   domain     = var.domain
#   public_ips = module.provider.public_ips
#   hostnames  = module.provider.hostnames
# }

module "wireguard" {
  source = "github.com/hobby-kube/provisioning//security/wireguard?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  node_count   = var.node_count
  connections  = module.provider.public_ips
  private_ips  = module.provider.private_ips
  hostnames    = module.provider.hostnames
  overlay_cidr = module.kubernetes.overlay_cidr
}

module "firewall" {
  source = "github.com/hobby-kube/provisioning//security/ufw?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  node_count           = var.node_count
  connections          = module.provider.public_ips
  private_interface    = module.provider.private_network_interface
  vpn_interface        = module.wireguard.vpn_interface
  vpn_port             = module.wireguard.vpn_port
  kubernetes_interface = module.kubernetes.overlay_interface
}

module "etcd" {
  source = "github.com/hobby-kube/provisioning//service/etcd?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  node_count  = var.etcd_node_count
  connections = module.provider.public_ips
  hostnames   = module.provider.hostnames
  vpn_unit    = module.wireguard.vpn_unit
  vpn_ips     = module.wireguard.vpn_ips
}

module "kubernetes" {
  source = "github.com/hobby-kube/provisioning//service/kubernetes?ref=800d5d5031245cf31a803a147eaa40a0de0573f1"

  node_count     = var.node_count
  connections    = module.provider.public_ips
  cluster_name   = var.domain
  vpn_interface  = module.wireguard.vpn_interface
  vpn_ips        = module.wireguard.vpn_ips
  etcd_endpoints = module.etcd.endpoints
}

// Volume used by rook in k8s to provide block storage
resource hcloud_volume rook_storage {
  name = "rook_storage_${count.index + 1}"
  size = 10
  server_id = data.hcloud_server.hosts[count.index].id
  automount = false
  count = var.node_count
}

data hcloud_server hosts {
  name = module.provider.hostnames[count.index]
  count = var.node_count
}
