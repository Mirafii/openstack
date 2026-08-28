# Une équipe SI = une entrée dans var.teams (voir teams.auto.tfvars.example)
# = un projet OpenStack isolé, provisionné par le module team-project.
#
# Pour ajouter une équipe : voir docs/adding-a-team.md.

module "team" {
  source = "./modules/team-project"

  for_each = var.teams

  team_name              = each.key
  domain_name            = each.value.domain_name
  description            = each.value.description
  subnet_cidr            = each.value.subnet_cidr
  quota_instances        = each.value.quota_instances
  external_network_name  = var.external_network_name
}

output "teams" {
  description = "Récapitulatif des projets créés : project_id / network_id / security_group à réutiliser pour déployer des VMs dans chaque projet."
  value = {
    for name, team in module.team : name => {
      project_id           = team.project_id
      network_id           = team.network_id
      security_group_name  = team.security_group_name
      domain_name          = team.domain_name
    }
  }
}
