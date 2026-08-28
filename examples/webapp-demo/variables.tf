variable "team_name" {
  description = "Nom du projet de démo."
  type        = string
  default     = "demo"
}

variable "domain_name" {
  description = "Nom de domaine prévu pour ce site de démo (purement informatif + affiché sur la page)."
  type        = string
  default     = "demo.example.lab"
}

variable "external_network_name" {
  type    = string
  default = "public1"
}

variable "image_name" {
  description = "Nom de l'image Glance à utiliser (voir deploy/kolla-ansible/init-cloud-resources.sh)."
  type        = string
  default     = "ubuntu-22.04"
}

variable "flavor_name" {
  type    = string
  default = "m1.small"
}

variable "ssh_public_key" {
  description = "Clé publique SSH à injecter dans la VM (contenu d'un .pub). Laisser vide pour ne pas créer d'accès SSH."
  type        = string
  default     = ""
}
