#!/usr/bin/env bash

# 1. Pastikan script dijalankan sebagai root (sudo)
if [[ $EUID -ne 0 ]]; then
   echo "[!] Script ini harus dijalankan dengan sudo: sudo ./install.sh"
   exit 1
fi

# 2. Dapatkan path direktori tempat script ini disimpan
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="Fantasi-Grub"
GRUB_CONFIG="/etc/default/grub"

# Deteksi folder themes (dukung /boot/grub dan /boot/grub2)
if [[ -d "/boot/grub2" ]]; then
    THEME_DIR="/boot/grub2/themes"
else
    THEME_DIR="/boot/grub/themes"
fi

echo "[*] Memulai instalasi tema ${THEME_NAME}..."

# Buat folder themes jika belum ada
mkdir -p "${THEME_DIR}"

# Salin folder tema dari lokasi script
echo "[*] Menyalin file tema..."
cp -r "${SCRIPT_DIR}/${THEME_NAME}" "${THEME_DIR}/"

# Backup konfigurasi GRUB bawaan
if [[ -f "${GRUB_CONFIG}" ]]; then
    cp "${GRUB_CONFIG}" "${GRUB_CONFIG}.bak"
    echo "[*] Berhasil backup ${GRUB_CONFIG} ke ${GRUB_CONFIG}.bak"
fi

# Atur baris GRUB_THEME di /etc/default/grub
sed -i '/^GRUB_THEME=/d' "${GRUB_CONFIG}"
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> "${GRUB_CONFIG}"

# Perbarui GRUB sesuai distro yang dipakai
echo "[*] Memperbarui konfigurasi bootloader GRUB..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub2-mkconfig &> /dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
elif command -v grub-mkconfig &> /dev/null; then
    if [[ -f "/boot/grub/grub.cfg" ]]; then
        grub-mkconfig -o /boot/grub/grub.cfg
    elif [[ -f "/boot/grub2/grub.cfg" ]]; then
        grub-mkconfig -o /boot/grub2/grub.cfg
    else
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
else
    echo "[!] Perintah update grub tidak ditemukan, silakan perbarui grub secara manual."
fi

echo "[✓] Instalasi selesai! Silakan reboot untuk melihat hasilnya."
