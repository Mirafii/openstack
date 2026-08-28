# Exemple de premier projet web : une VM Nova + nginx servant une page
# statique, dans son propre projet OpenStack ("demo"), avec sa propre IP
# flottante. Sert de modèle pour ce qu'une équipe SI ferait pour son propre
# site — voir docs/adding-a-team.md.

module "team" {
  source = "../../infra/terraform/modules/team-project"

  team_name              = var.team_name
  domain_name            = var.domain_name
  description            = "Projet de démonstration : VM Nova + nginx"
  external_network_name  = var.external_network_name
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_compute_keypair_v2" "this" {
  count      = var.ssh_public_key != "" ? 1 : 0
  name       = "${var.team_name}-key"
  public_key = var.ssh_public_key
}

locals {
  index_html = templatefile("${path.module}/site/index.html", {
    team_name   = var.team_name
    domain_name = var.domain_name
  })
}

resource "openstack_compute_instance_v2" "web" {
  name            = "${var.team_name}-web"
  tenant_id       = module.team.project_id
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.ssh_public_key != "" ? openstack_compute_keypair_v2.this[0].name : null
  security_groups = [module.team.security_group_name]

  network {
    uuid = module.team.network_id
  }

  user_data = templatefile("${path.module}/cloud-init.yaml.tpl", {
    index_html = local.index_html
  })
}

resource "openstack_networking_floatingip_v2" "web" {
  tenant_id = module.team.project_id
  pool      = data.openstack_networking_network_v2.external.name
}

resource "openstack_compute_floatingip_associate_v2" "web" {
  floating_ip = openstack_networking_floatingip_v2.web.address
  instance_id = openstack_compute_instance_v2.web.id
}
