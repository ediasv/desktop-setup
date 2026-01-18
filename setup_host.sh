#!/bin/bash
set -e

echo "### INICIANDO SETUP DO HOST (FEDORA ATOMIC) ###"

# --- 1. Pacotes do Sistema ---
SYSTEM_PKGS=(
  "distrobox"
  "alacritty"
  "tmux"
  "stow"
  "wireguard-tools"
)

echo ">> Instalando pacotes do sistema..."
rpm-ostree install -y --apply-live --idempotent "${SYSTEM_PKGS[@]}"

# --- 2. Flatpaks ---
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

# --- 3. Configuração de Fontes (CORRIGIDO) ---
echo ">> Configurando fonte do sistema..."

# Define diretórios e garante que o diretório de destino pertença ao usuário atual
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Cria um diretório temporário para o download (evita erro de permissão no diretório atual)
TEMP_DIR=$(mktemp -d)

echo "Baixando JetBrains Mono..."
# Baixa para a pasta temporária
curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "$TEMP_DIR/JetBrainsMono.tar.xz"

echo "Extraindo fontes..."
# Extrai direto do temp para o destino
tar -xf "$TEMP_DIR/JetBrainsMono.tar.xz" -C "$FONT_DIR"

# Limpeza
rm -rf "$TEMP_DIR"
fc-cache -vf "$FONT_DIR"

# --- 4. Dotfiles (CORRIGIDO) ---
echo ">> Aplicando configurações do usuário com GNU Stow..."

# Verifica se a pasta já existe para evitar erro no git clone
if [ -d "$HOME/dotfiles" ]; then
  echo "Pasta dotfiles já existe. Atualizando..."
  cd "$HOME/dotfiles" && git pull
else
  git clone https://github.com/ediasv/dotfiles.git "$HOME/dotfiles"
  cd "$HOME/dotfiles"
fi

# Loop seguro: Só aplica stow em diretórios que não sejam ocultos (.git)
for dir in *; do
  if [ -d "$dir" ] && [ "$dir" != ".git" ]; then
    echo "Stowing $dir..."
    stow "$dir"
  fi
done

echo "### SETUP DO HOST CONCLUÍDO ###"
