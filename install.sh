#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "[!] Script ini harus dijalankan dengan sudo: sudo ./install.sh"
   exit 1
fi

THEME_NAME="Fantasi-Grub"
THEME_DIR="/boot/grub/themes"
GRUB_CONFIG="/etc/default/grub"

echo "[*] Memulai instalasi tema ${THEME_NAME}..."
mkdir -p "${THEME_DIR}"
cp -r "${THEME_NAME}" "${THEME_DIR}/"
cp "${GRUB_CONFIG}" "${GRUB_CONFIG}.bak"

sed -i '/^GRUB_THEME=/d' "${GRUB_CONFIG}"
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> "${GRUB_CONFIG}"

echo "[*] Memperbarui GRUB..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "[✓] Instalasi selesai! Silakan reboot laptopmu untuk melihat hasilnya."
