terraform {
  required_version = ">= 1.5.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.0.0"
    }
  }
}

# Authentification : source /chemin/vers/admin-openrc.sh (généré par
# deploy/kolla-ansible/deploy.sh) avant de lancer terraform. Le provider lit
# les variables d'environnement OS_* automatiquement, pas de bloc à remplir.
provider "openstack" {}
