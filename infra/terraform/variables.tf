variable "teams" {
  description = "Une entrée par équipe SI à provisionner. Voir teams.auto.tfvars.example."
  type = map(object({
    domain_name    = string
    description    = optional(string, "")
    subnet_cidr    = optional(string, "192.168.100.0/24")
    quota_instances = optional(number, 10)
  }))
}

variable "external_network_name" {
  description = "Nom du réseau externe Neutron déjà créé (voir deploy/kolla-ansible/init-cloud-resources.sh)."
  type        = string
  default     = "public1"
}
