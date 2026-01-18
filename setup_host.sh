#!/bin/bash
set -e

echo "### INICIANDO SETUP DO HOST (FEDORA ATOMIC) ###"

SYSTEM_PKGS=(
  "distrobox"
  "alacritty"
  "tmux"
)

echo ">> Instalando pacotes do sistema..."
rpm-ostree install --apply-live --idempotent "${SYSTEM_PKGS[@]}"

echo ">> Configurando Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAK_LIST=(
  "com.usebruno.Bruno"
  "io.dbeaver.DBeaverCommunity"
  "com.bitwarden.desktop"
  "io.github.pwr_solaar.solaar"
  "md.obsidian.Obsidian"
  "org.fedoraproject.MediaWriter"
  "org.libreoffice.LibreOffice"
  "com.stremio.Stremio"
  "org.gnome.Calculator"
  "org.flameshot.Flameshot"
)

echo ">> Instalando Flatpaks..."
flatpak install -y flathub "${FLATPAK_LIST[@]}"

echo "### SETUP DO HOST CONCLUÍDO ###"
