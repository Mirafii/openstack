terraform {
  required_version = ">= 1.5.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.0.0"
    }
  }
}

# Authentification : source /chemin/vers/admin-openrc.sh avant de lancer
# terraform (mêmes identifiants que infra/terraform).
provider "openstack" {}
