# Module "team-project" : provisionne tout ce dont une équipe SI a besoin
# pour déployer ses propres sites web sur OpenStack, isolée des autres
# équipes.
#
# Crée : 1 projet Keystone, 1 réseau privé + sous-réseau, 1 routeur vers le
# réseau externe, 1 security group de base (SSH/HTTP/HTTPS), des quotas.
#
# Voir docs/architecture.md pour le rationale du choix "1 projet par équipe".

data "openstack_identity_domain_v3" "this" {
  name = var.domain_id_name
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_identity_project_v3" "this" {
  name        = var.team_name
  domain_id   = data.openstack_identity_domain_v3.this.id
  description = var.description != "" ? var.description : "Projet OpenStack de l'équipe ${var.team_name} (domaine web: ${var.domain_name})"
  enabled     = true
}

resource "openstack_networking_network_v2" "private" {
  name       = "${var.team_name}-net"
  tenant_id  = openstack_identity_project_v3.this.id
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private" {
  name            = "${var.team_name}-subnet"
  tenant_id       = openstack_identity_project_v3.this.id
  network_id      = openstack_networking_network_v2.private.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_router_v2" "this" {
  name                = "${var.team_name}-router"
  tenant_id           = openstack_identity_project_v3.this.id
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "this" {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.private.id
}

resource "openstack_networking_secgroup_v2" "web" {
  name        = "${var.team_name}-web"
  tenant_id   = openstack_identity_project_v3.this.id
  description = "SSH + HTTP + HTTPS pour les VMs web de l'équipe ${var.team_name}"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  tenant_id          = openstack_identity_project_v3.this.id
  direction          = "ingress"
  ethertype          = "IPv4"
  protocol           = "tcp"
  port_range_min     = 22
  port_range_max     = 22
  remote_ip_prefix   = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  tenant_id          = openstack_identity_project_v3.this.id
  direction          = "ingress"
  ethertype          = "IPv4"
  protocol           = "tcp"
  port_range_min     = 80
  port_range_max     = 80
  remote_ip_prefix   = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  tenant_id          = openstack_identity_project_v3.this.id
  direction          = "ingress"
  ethertype          = "IPv4"
  protocol           = "tcp"
  port_range_min     = 443
  port_range_max     = 443
  remote_ip_prefix   = "0.0.0.0/0"
}

resource "openstack_compute_quotaset_v2" "this" {
  project_id = openstack_identity_project_v3.this.id
  instances  = var.quota_instances
  cores      = var.quota_cores
  ram        = var.quota_ram_mb
}

resource "openstack_networking_quota_v2" "this" {
  project_id  = openstack_identity_project_v3.this.id
  floatingip  = var.quota_floating_ips
  network     = var.quota_networks
  subnet      = var.quota_networks
  router      = 2
  security_group = 5
}
