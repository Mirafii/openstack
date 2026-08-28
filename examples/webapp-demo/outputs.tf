output "floating_ip" {
  description = "IP flottante publique du site de démo. Pointe le domaine (var.domain_name) vers cette IP en DNS (enregistrement A), ou ajoute une ligne dans /etc/hosts pour tester en local."
  value       = openstack_networking_floatingip_v2.web.address
}

output "domain_name" {
  value = var.domain_name
}

output "suggested_dns_record" {
  value = "${var.domain_name}.  IN  A  ${openstack_networking_floatingip_v2.web.address}"
}

output "project_id" {
  value = module.team.project_id
}
