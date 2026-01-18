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

echo ">> Verificando pacotes do sistema..."
# rpm-ostree é inerentemente idempotente com este comando, mas pode ser lento.
# Mantivemos sua flag --idempotent.
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
# O Flatpak ignora automaticamente o que já está instalado, mas o output pode ser verboso.
flatpak install -y flathub "${FLATPAK_LIST[@]}"

# --- 3. Configuração de Fontes (OTIMIZADO) ---
echo ">> Configurando fonte do sistema..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Verifica se a fonte já existe para não baixar novamente
if ls "$FONT_DIR"/JetBrainsMono*.ttf 1>/dev/null 2>&1; then
  echo "JetBrains Mono já está instalada. Pulando..."
else
  echo "Baixando JetBrains Mono..."
  TEMP_DIR=$(mktemp -d)

  curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "$TEMP_DIR/JetBrainsMono.tar.xz"

  echo "Extraindo fontes..."
  tar -xf "$TEMP_DIR/JetBrainsMono.tar.xz" -C "$FONT_DIR"

  rm -rf "$TEMP_DIR"
  fc-cache -vf "$FONT_DIR"
fi

# --- 4. Dotfiles (CORRIGIDO) ---
echo ">> Aplicando configurações do usuário com GNU Stow..."

if [ -d "$HOME/dotfiles" ]; then
  echo "Pasta dotfiles já existe. Atualizando..."
  cd "$HOME/dotfiles" && git pull
else
  git clone https://github.com/ediasv/dotfiles.git "$HOME/dotfiles"
  cd "$HOME/dotfiles"
fi

# Função para fazer backup de arquivos padrão do Fedora que conflitam com o Stow
# O Stow falha se o destino for um arquivo real, ele só sobrescreve se for um symlink antigo.
backup_if_conflict() {
  local target="$HOME/$1"
  if [ -f "$target" ] && [ ! -L "$target" ]; then
    echo "Conflito detectado: $target é um arquivo real. Movendo para $target.bak"
    mv "$target" "$target.bak"
  fi
}

# Lista de arquivos comuns que costumam dar conflito em instalações novas
# Adicione outros aqui se tiver erros com outros arquivos (ex: .zshrc, .config/mimeapps.list)
backup_if_conflict ".bashrc"
backup_if_conflict ".bash_profile"

# Loop seguro com Stow -R (Restow)
for dir in *; do
  if [ -d "$dir" ] && [ "$dir" != ".git" ]; then
    echo "Stowing (Restow) $dir..."
    # -R (Restow) é crucial para re-execução: atualiza links existentes e cria novos
    stow -R "$dir"
  fi
done

echo "### SETUP DO HOST CONCLUÍDO ###"
