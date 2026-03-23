#!/usr/bin/env bash
# Mount the 200GB OCI block volume and configure k3s to use it for PVC storage.
# Run as root: sudo bash scripts/05-mount-block-volume.sh
# Run BEFORE installing k3s.
set -euo pipefail

MOUNT_POINT="/mnt/app-data"
LOCAL_PATH_DIR="${MOUNT_POINT}/local-path-provisioner"

# OCI paravirtualized volumes show up as /dev/sdb (or /dev/oracleoci/oraclevdb)
# If /dev/sdb doesn't exist, check: ls /dev/oracleoci/
DEVICE="/dev/sdb"
if [ ! -b "${DEVICE}" ]; then
  DEVICE="/dev/oracleoci/oraclevdb"
fi

if [ ! -b "${DEVICE}" ]; then
  echo "ERROR: Block device not found. Check 'lsblk' output."
  lsblk
  exit 1
fi

echo "Found block device: ${DEVICE}"
lsblk "${DEVICE}"

# Format only if not already formatted
if ! blkid "${DEVICE}" &>/dev/null; then
  echo "Formatting ${DEVICE} as ext4..."
  mkfs.ext4 -F "${DEVICE}"
else
  echo "${DEVICE} is already formatted ($(blkid -s TYPE -o value "${DEVICE}")). Skipping format."
fi

# Mount
mkdir -p "${MOUNT_POINT}"
if mountpoint -q "${MOUNT_POINT}"; then
  echo "${MOUNT_POINT} is already mounted."
else
  mount "${DEVICE}" "${MOUNT_POINT}"
  echo "Mounted ${DEVICE} at ${MOUNT_POINT}"
fi

# Persist across reboots via fstab (using UUID for reliability)
DEVICE_UUID=$(blkid -s UUID -o value "${DEVICE}")
if ! grep -q "${DEVICE_UUID}" /etc/fstab; then
  echo "UUID=${DEVICE_UUID} ${MOUNT_POINT} ext4 defaults,_netdev,nofail 0 2" >> /etc/fstab
  echo "Added fstab entry for UUID=${DEVICE_UUID}"
fi

# Create the directory k3s local-path-provisioner will use for PVCs
mkdir -p "${LOCAL_PATH_DIR}"
echo "Created PVC storage directory: ${LOCAL_PATH_DIR}"

echo ""
echo "Block volume mounted successfully at ${MOUNT_POINT}"
echo "df -h ${MOUNT_POINT}:"
df -h "${MOUNT_POINT}"
