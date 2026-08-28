# Infra OpenStack multi-équipes

Infrastructure as code pour déployer, sur un cloud OpenStack de lab, un
projet OpenStack isolé par équipe SI, chaque équipe pouvant y héberger ses
sites web sous son propre nom de domaine. Un premier projet exemple (VM
Nova + nginx) sert de preuve de fonctionnement.

Voir [docs/architecture.md](docs/architecture.md) pour le détail des choix
(isolation par projet, routage par IP flottante + DNS, Kolla-Ansible plutôt
que DevStack).

## Prérequis

- Un accès **SSH avec sudo** à une machine Linux (Ubuntu 22.04 recommandé,
  8 Go RAM / 2 vCPU / 20 Go disque minimum), dédiée à cette maquette.
- Idéalement 2 interfaces réseau sur cette machine : une pour la gestion
  (SSH, IP fixe), une pour le "réseau externe" Neutron par lequel sortiront
  les IP flottantes. Une seule interface fonctionne aussi (voir les
  commentaires dans `globals.yml.example`) mais demande d'adapter la config
  réseau (bridge partagé).
- [Terraform](https://developer.hashicorp.com/terraform/install) installé
  sur ta machine de travail (celle d'où tu lances `terraform apply` — peut
  être la machine Linux elle-même, ou ton poste, du moment qu'elle peut
  atteindre l'API OpenStack déployée).

## 1. Déployer OpenStack (Kolla-Ansible All-In-One)

Sur la machine Linux cible, en SSH :

```bash
git clone <ce repo> && cd openstack/deploy/kolla-ansible
./bootstrap.sh
# édite globals.yml (network_interface, neutron_external_interface, kolla_internal_vip_address)
./deploy.sh
./init-cloud-resources.sh   # crée le réseau externe, une image Ubuntu, des flavors de base
```

`deploy.sh` génère `admin-openrc.sh` (identifiants admin OpenStack) dans ce
même dossier — **ne le commite jamais** (déjà dans `.gitignore`).

## 2. Provisionner les projets d'équipe (Terraform)

Depuis ta machine de travail, avec les identifiants OpenStack en variables
d'environnement :

```bash
source deploy/kolla-ansible/admin-openrc.sh   # ou copie ce fichier localement
cd infra/terraform
cp teams.auto.tfvars.example teams.auto.tfvars   # adapte la liste des équipes
terraform init
terraform apply
```

Chaque entrée de `teams.auto.tfvars` devient un projet OpenStack isolé
(réseau privé, routeur, security group, quotas). Voir
[docs/adding-a-team.md](docs/adding-a-team.md) pour ajouter une équipe plus
tard.

## 3. Déployer le site exemple

```bash
source deploy/kolla-ansible/admin-openrc.sh
cd examples/webapp-demo
terraform init
terraform apply
```

En sortie, `terraform output floating_ip` donne l'IP publique du site.
Configure le DNS du domaine (`terraform output domain_name`) vers cette IP —
ou ajoute une ligne dans `/etc/hosts` pour tester en local — puis :

```bash
curl -H "Host: $(terraform output -raw domain_name)" http://$(terraform output -raw floating_ip)
```

## Structure du repo

```
deploy/kolla-ansible/   # déploiement d'OpenStack lui-même (Kolla-Ansible AIO)
infra/terraform/        # provisioning des projets d'équipe (module réutilisable)
examples/webapp-demo/   # premier site exemple : VM Nova + nginx
docs/                   # architecture et guides
```
