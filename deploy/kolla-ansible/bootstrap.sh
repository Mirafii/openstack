#!/usr/bin/env bash
#
# Prépare la machine Linux cible pour un déploiement Kolla-Ansible All-In-One.
# À exécuter EN SSH sur la machine Linux (Ubuntu 22.04 recommandé), depuis ce
# dossier, avec un utilisateur sudo :
#
#   ./bootstrap.sh
#
set -euo pipefail

KOLLA_ANSIBLE_VERSION="${KOLLA_ANSIBLE_VERSION:-master}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${HERE}/.venv"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Ne lance pas ce script en root direct : utilise un user sudo (sudo sera appelé au besoin)." >&2
  exit 1
fi

echo "==> Installation des paquets système requis"
sudo apt-get update
sudo apt-get install -y python3-dev python3-venv python3-pip libffi-dev gcc libssl-dev git

echo "==> Création du virtualenv Python (${VENV_DIR})"
python3 -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
pip install -U pip

echo "==> Installation de kolla-ansible (${KOLLA_ANSIBLE_VERSION}) et d'ansible"
pip install "git+https://opendev.org/openstack/kolla-ansible@${KOLLA_ANSIBLE_VERSION}"

echo "==> Installation des dépendances Ansible de Kolla"
KOLLA_SHARE="$(python3 -c 'import kolla_ansible; import os; print(os.path.dirname(kolla_ansible.__file__))')"
sudo mkdir -p /etc/kolla
sudo chown "$(whoami):$(whoami)" /etc/kolla
cp -r "${VENV_DIR}"/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/ 2>/dev/null || true
kolla-ansible install-deps

echo "==> Copie de l'inventaire All-In-One"
cp "${HERE}/inventory/all-in-one" /etc/kolla/multinode 2>/dev/null || true

if [[ ! -f "${HERE}/globals.yml" ]]; then
  echo "==> Pas de globals.yml : copie de globals.yml.example"
  cp "${HERE}/globals.yml.example" "${HERE}/globals.yml"
  echo
  echo "!!! IMPORTANT : édite ${HERE}/globals.yml avant de lancer deploy.sh :"
  echo "    - network_interface (interface réseau de gestion, ex: eth0)"
  echo "    - neutron_external_interface (interface pour le réseau externe/IP flottantes)"
  echo "    - kolla_internal_vip_address (IP libre sur le réseau de gestion)"
fi

echo
echo "Bootstrap terminé. Étape suivante : édite globals.yml puis lance ./deploy.sh"
