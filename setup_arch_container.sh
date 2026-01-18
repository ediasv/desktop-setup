#!/bin/bash
set -e

CONTAINER_NAME="arch"
IMAGE="docker.io/library/archlinux:latest"

ARCH_PKGS=(
  "base" "base-devel" "git" "man-db" "man-pages"
  "fish" "starship" "tmux" "stow"
  "bat" "eza" "fd" "fzf" "ripgrep" "fastfetch" "btop" "lazygit"
  "unrar" "unzip" "wget" "tree" "inotify-tools" "less"
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
  "nwg-look"
  "qt6ct"
  "libpulse"
  "docker-compose"
  "lazydocker"
)

PKGS_STRING="${ARCH_PKGS[*]}"

echo "### Beginning Arch Linux container setup ###"

if distrobox list | grep -q "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' already exists."
else
  echo "Creating container '$CONTAINER_NAME'..."
  distrobox create --name "$CONTAINER_NAME" --image "$IMAGE" --yes
fi

echo "Initializing Update and Bootstrap..."

distrobox enter "$CONTAINER_NAME" -- sh -c "
    # Atualiza chaves e sistema básico
    sudo pacman -Sy --noconfirm archlinux-keyring
    sudo pacman -Syu --noconfirm

    # Instala pré-requisitos para compilar o Yay
    sudo pacman -S --noconfirm --needed base-devel git
"

echo "Installing Yay (AUR Helper)..."
distrobox enter "$CONTAINER_NAME" -- sh -c "
    if ! command -v yay &> /dev/null; then
        cd /tmp
        rm -rf yay
        git clone https://aur.archlinux.org/yay.git
        cd yay
        # makepkg não pode rodar como root, mas o distrobox roda como user
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo 'Yay is already installed.'
    fi
"

echo "Installing full package list..."
distrobox enter "$CONTAINER_NAME" -- sh -c "
    yay -S --noconfirm --needed $PKGS_STRING
"

echo "### CONTAINER SETUP FINISHED ###"
