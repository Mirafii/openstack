# Ajouter une nouvelle équipe SI

Prérequis : OpenStack déjà déployé (voir [README.md](../README.md)) et
`admin-openrc.sh` sourcé dans le shell.

1. Ouvre `infra/terraform/teams.auto.tfvars` (créé à partir de
   `teams.auto.tfvars.example` si ce n'est pas déjà fait) et ajoute une
   entrée :

   ```hcl
   teams = {
     # ... équipes existantes ...
     "equipe-compta" = {
       domain_name = "compta.example.lab"
       subnet_cidr = "192.168.103.0/24"   # choisis un CIDR pas déjà utilisé
     }
   }
   ```

2. Applique :

   ```bash
   cd infra/terraform
   terraform apply
   ```

3. Récupère les identifiants du projet créé :

   ```bash
   terraform output -json teams | jq '."equipe-compta"'
   ```

   Tu obtiens `project_id`, `network_id`, `security_group_name`.

4. Déploie une VM web dans ce projet, sur le même modèle que
   [examples/webapp-demo](../examples/webapp-demo) : un dossier Terraform
   avec une `openstack_compute_instance_v2` référençant ce `network_id` /
   `security_group_name`, une IP flottante, et un `cloud-init` qui installe
   nginx (ou toute autre stack) et sert le site de l'équipe. Le plus simple
   est de dupliquer `examples/webapp-demo/` en changeant `team_name` /
   `domain_name` dans les variables, et en remplaçant `site/index.html` par
   le vrai contenu de l'équipe.

5. Une fois la VM créée, note l'IP flottante en sortie Terraform et
   configure le DNS du domaine de l'équipe (enregistrement `A`) — ou une
   ligne `/etc/hosts` pour un test en local — pour qu'il pointe vers cette
   IP.
