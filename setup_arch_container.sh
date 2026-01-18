#!/bin/bash
set -e

CONTAINER_NAME="arch"
IMAGE="docker.io/library/archlinux:latest"

echo "### Beginning Arch Linux container setup ###"

# Cria container se não existir
if distrobox list | grep -q "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' already exists."
else
  echo "Creating container '$CONTAINER_NAME'..."
  distrobox create --name "$CONTAINER_NAME" --image "$IMAGE" --yes
fi

echo "Installing packages on Arch..."
distrobox enter "$CONTAINER_NAME" -- sh -c "
    sudo pacman -Sy --noconfirm archlinux-keyring
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed \
        base-devel \
        git \
        neovim \
        tmux \
        fish \
        starship \
        ripgrep \
        fzf \
        bat \
        eza \
        wl-clipboard \
        nodejs npm \
        python python-pip
"

echo "Configuring Zsh..."
distrobox enter "$CONTAINER_NAME" -- sh -c "sudo chsh -s /usr/bin/zsh \$(whoami)"

echo "### CONTAINER SETUP FINISHED ###"
