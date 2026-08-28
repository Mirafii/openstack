#!/usr/bin/env bash
#
# Déploie OpenStack (Kolla-Ansible All-In-One) sur la machine courante.
# À lancer APRÈS bootstrap.sh et après avoir édité globals.yml.
#
#   ./deploy.sh
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${HERE}/.venv"

if [[ ! -d "${VENV_DIR}" ]]; then
  echo "Venv introuvable (${VENV_DIR}). Lance d'abord ./bootstrap.sh" >&2
  exit 1
fi
if [[ ! -f "${HERE}/globals.yml" ]]; then
  echo "globals.yml introuvable. Lance d'abord ./bootstrap.sh puis édite-le." >&2
  exit 1
fi

source "${VENV_DIR}/bin/activate"
cp "${HERE}/globals.yml" /etc/kolla/globals.yml

echo "==> Génération des mots de passe (passwords.yml)"
kolla-genpwd

echo "==> bootstrap-servers"
kolla-ansible -i "${HERE}/inventory/all-in-one" bootstrap-servers

echo "==> prechecks"
kolla-ansible -i "${HERE}/inventory/all-in-one" prechecks

echo "==> deploy (peut prendre 20-40 min selon la machine)"
kolla-ansible -i "${HERE}/inventory/all-in-one" deploy

echo "==> post-deploy (génère /etc/kolla/admin-openrc.sh)"
kolla-ansible -i "${HERE}/inventory/all-in-one" post-deploy

cp /etc/kolla/passwords.yml "${HERE}/passwords.yml"
cp /etc/kolla/admin-openrc.sh "${HERE}/admin-openrc.sh"

echo
echo "OpenStack est déployé. Identifiants admin : ${HERE}/admin-openrc.sh"
echo "Prochaine étape : ./init-cloud-resources.sh pour créer le réseau externe,"
echo "une image et des flavors de base (nécessaires à Terraform)."
