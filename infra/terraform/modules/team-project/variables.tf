variable "team_name" {
  description = "Nom court de l'équipe SI (slug, ex: \"equipe-marketing\"). Utilisé comme nom de projet OpenStack et préfixe des ressources réseau."
  type        = string
}

variable "domain_name" {
  description = "Nom de domaine public que cette équipe utilisera pour son/ses site(s) web (ex: \"marketing.example.lab\"). Purement informatif côté Terraform : stocké en description, utile pour docs/adding-a-team.md."
  type        = string
}

variable "description" {
  description = "Description libre du projet, affichée dans Horizon/openstack CLI."
  type        = string
  default     = ""
}

variable "external_network_name" {
  description = "Nom du réseau externe Neutron déjà créé (voir deploy/kolla-ansible/init-cloud-resources.sh)."
  type        = string
  default     = "public1"
}

variable "domain_id_name" {
  description = "Nom du domaine Keystone dans lequel créer le projet (le domaine par défaut Kolla-Ansible s'appelle \"Default\")."
  type        = string
  default     = "Default"
}

variable "subnet_cidr" {
  description = "CIDR du réseau privé de l'équipe. Chaque équipe étant isolée derrière son propre routeur, les CIDR peuvent se recouper entre équipes sans problème — garde-les simplement uniques si tu veux un jour peer entre deux projets."
  type        = string
  default     = "192.168.100.0/24"
}

variable "dns_nameservers" {
  description = "Résolveurs DNS donnés aux VMs de l'équipe via DHCP."
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "quota_instances" {
  type    = number
  default = 10
}

variable "quota_cores" {
  type    = number
  default = 20
}

variable "quota_ram_mb" {
  type    = number
  default = 51200
}

variable "quota_floating_ips" {
  type    = number
  default = 5
}

variable "quota_networks" {
  type    = number
  default = 5
}
