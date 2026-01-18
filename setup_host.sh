#!/bin/bash
set -e

echo "### INICIANDO SETUP DO HOST (FEDORA ATOMIC) ###"

SYSTEM_PKGS=(
  "distrobox"
  "alacritty"
  "tmux"
  "stow"
  "wireguard-tools"
)

echo ">> Instalando pacotes do sistema..."
rpm-ostree install -y --apply-live --idempotent "${SYSTEM_PKGS[@]}"

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
  "org.gnome.Calculator"
  "org.flameshot.Flameshot"
)

echo ">> Instalando Flatpaks..."
flatpak install -y flathub "${FLATPAK_LIST[@]}"

echo ">> Configurando fonte do sistema"
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
sudo mkdir -p ~/.local/share/fonts/
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts
rm JetBrainsMono.tar.xz
fc-cache -vf ~/.local/share/fonts/

echo ">> Aplicando configurações do usuário com GNU Stow..."
git clone https://github.com/ediasv/dotfiles.git
for dir in *; do
  [ -d "$dir" ] && [ "$dir" != ".git" ] && stow "$dir"
done

echo "### SETUP DO HOST CONCLUÍDO ###"
