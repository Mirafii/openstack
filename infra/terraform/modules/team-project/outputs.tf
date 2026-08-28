output "project_id" {
  description = "ID du projet Keystone de l'équipe — à réutiliser pour créer des VMs dans ce projet."
  value       = openstack_identity_project_v3.this.id
}

output "project_name" {
  value = openstack_identity_project_v3.this.name
}

output "network_id" {
  description = "ID du réseau privé de l'équipe — à utiliser comme réseau de rattachement des VMs."
  value       = openstack_networking_network_v2.private.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.private.id
}

output "router_id" {
  value = openstack_networking_router_v2.this.id
}

output "security_group_name" {
  description = "Security group SSH/HTTP/HTTPS à attacher aux VMs web de l'équipe."
  value       = openstack_networking_secgroup_v2.web.name
}

output "domain_name" {
  value = var.domain_name
}
