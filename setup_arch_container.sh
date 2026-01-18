#!/bin/bash
set -e

CONTAINER_NAME="arch"
IMAGE="docker.io/library/archlinux:latest"
ARCH_PKGS=(
  # --- Base do Arch ---
  "base"
  "base-devel"
  "yay"
  "git"
  "man-db"
  "man-pages"

  # --- Shell e Terminal ---
  "fish"
  "starship"
  "tmux"
  "stow"

  # --- Ferramentas CLI Modernas ---
  "bat"
  "eza"
  "fd"
  "fzf"
  "ripgrep"
  "fastfetch"
  "btop"
  "lazygit"
  "unrar"
  "unzip"
  "wget"
  "tree"
  "inotify-tools"
  "less"

  # --- Desenvolvimento (Editores e Suporte) ---
  "neovim-nightly-bin"
  "zed"
  "python-pipx"
  "mise"
  "tree-sitter-cli"
  "ast-grep"
  "shellcheck"
  "markdownlint-cli2"
  "prettier"
  "lua51"
  "luarocks"

  # --- GUI / Temas (Exportados) ---
  "nwg-look" # Melhor que lxappearance para Wayland/Sway
  "qt6ct"    # Para temas QT
  "libpulse" # Compatibilidade de áudio

  # --- Docker Clients (Sem o Daemon) ---
  "docker-compose" # Funciona conectando no socket do Podman do host
  "lazydocker"     # Funciona conectando no socket do Podman do host
)

echo "### Beginning Arch Linux container setup ###"

if distrobox list | grep -q "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' already exists."
else
  echo "Creating container '$CONTAINER_NAME'..."
  distrobox create --name "$CONTAINER_NAME" --image "$IMAGE" --yes
fi

echo "Installing packages on Arch..."
distrobox enter "$CONTAINER_NAME" -- sh -c
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed "${ARCH_PKGS[@]}"

echo "### CONTAINER SETUP FINISHED ###"
