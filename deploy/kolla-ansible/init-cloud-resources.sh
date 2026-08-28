#!/usr/bin/env bash
#
# Kolla-Ansible déploie OpenStack mais ne crée ni réseau externe, ni image,
# ni flavor : ce script fait ce travail une fois, juste après deploy.sh, en
# tant qu'admin. Terraform (infra/terraform, examples/webapp-demo) suppose
# que ces ressources existent déjà (réseau externe "public1", image
# "ubuntu-22.04", flavors "m1.small" etc).
#
# À adapter : EXT_NET_CIDR / EXT_NET_GATEWAY / EXT_NET_ALLOCATION_START/END
# doivent correspondre au réseau physique réellement bridgé sur
# neutron_external_interface (voir globals.yml).
#
#   ./init-cloud-resources.sh
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${HERE}/admin-openrc.sh"

EXT_NET_NAME="${EXT_NET_NAME:-public1}"
EXT_NET_CIDR="${EXT_NET_CIDR:-10.0.2.0/24}"
EXT_NET_GATEWAY="${EXT_NET_GATEWAY:-10.0.2.1}"
EXT_NET_ALLOCATION_START="${EXT_NET_ALLOCATION_START:-10.0.2.100}"
EXT_NET_ALLOCATION_END="${EXT_NET_ALLOCATION_END:-10.0.2.200}"
UBUNTU_IMAGE_URL="${UBUNTU_IMAGE_URL:-https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img}"

echo "==> Réseau externe ${EXT_NET_NAME} (${EXT_NET_CIDR})"
if ! openstack network show "${EXT_NET_NAME}" &>/dev/null; then
  openstack network create --external \
    --provider-physical-network physnet1 \
    --provider-network-type flat \
    "${EXT_NET_NAME}"
  openstack subnet create \
    --network "${EXT_NET_NAME}" \
    --subnet-range "${EXT_NET_CIDR}" \
    --gateway "${EXT_NET_GATEWAY}" \
    --allocation-pool "start=${EXT_NET_ALLOCATION_START},end=${EXT_NET_ALLOCATION_END}" \
    --no-dhcp \
    "${EXT_NET_NAME}-subnet"
else
  echo "    déjà présent, on passe."
fi

echo "==> Image ubuntu-22.04"
if ! openstack image show ubuntu-22.04 &>/dev/null; then
  curl -L -o /tmp/jammy-server-cloudimg-amd64.img "${UBUNTU_IMAGE_URL}"
  openstack image create ubuntu-22.04 \
    --file /tmp/jammy-server-cloudimg-amd64.img \
    --disk-format qcow2 \
    --container-format bare \
    --public
  rm -f /tmp/jammy-server-cloudimg-amd64.img
else
  echo "    déjà présente, on passe."
fi

echo "==> Flavors de base"
declare -A FLAVORS=(
  [m1.tiny]="1 512 1"
  [m1.small]="1 2048 10"
  [m1.medium]="2 4096 20"
)
for name in "${!FLAVORS[@]}"; do
  read -r vcpus ram disk <<< "${FLAVORS[$name]}"
  if ! openstack flavor show "${name}" &>/dev/null; then
    openstack flavor create --vcpus "${vcpus}" --ram "${ram}" --disk "${disk}" "${name}"
  fi
done

echo
echo "Ressources de base créées. Tu peux maintenant lancer Terraform"
echo "(infra/terraform) en sourçant ${HERE}/admin-openrc.sh."
