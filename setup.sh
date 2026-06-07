#!/usr/bin/env bash

# =============================================================
# Ubuntu 26.04 LTS Development Environment Setup Script
# -------------------------------------------------------------
# This script installs a curated list of development tools, utilities,
# and user‑requested applications. It also configures the default
# GNOME Terminal to use Zsh (with a provided .zshrc) and Ghostty to use
# Bash (with a provided .bashrc).
#
# The script is designed to be idempotent – running it repeatedly will
# only install missing packages or skip already‑present configuration.
# =============================================================

set -euo pipefail
IFS=$'\n\t'

# --------------------------
# Helper Functions
# --------------------------
log() {
  echo -e "\e[1;34m[+] $*\e[0m"
}
error() {
  echo -e "\e[1;31m[!] $*\e[0m" >&2
  exit 1
}

# Ensure script runs with root privileges
if [ "$(id -u)" -ne 0 ]; then
  error "Please run this script with sudo or as root."
fi

# --------------------------
# Update & Upgrade System
# --------------------------
log "Updating package lists..."
apt-get update -y
log "Upgrading installed packages..."
apt-get upgrade -y

# --------------------------
# Install Essential Packages (tools & utilities)
# --------------------------
ESSENTIAL_PKGS=(
  curl
  wget
  git
  build-essential
  software-properties-common
  apt-transport-https
  ca-certificates
  gnupg
  unzip
  vim
  btop
  fastfetch
  gnome-tweaks
  gnome-shell-extensions
  extension-manager
  chrome-gnome-shell
  gnome-shell-extension-manager
  dconf-editor
)
log "Installing essential tools..."

apt-get install -y "${ESSENTIAL_PKGS[@]}"

# --------------------------
# Fastfetch Config Setup
# --------------------------
log "Generating Fastfetch default config..."
FASTFETCH_CONFIG_DIR="$HOME/.config/fastfetch"
mkdir -p "$FASTFETCH_CONFIG_DIR"
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch --gen-config > "$FASTFETCH_CONFIG_DIR/config.jsonc" || log "Fastfetch config generation failed, proceeding."
fi

# Copy custom Fastfetch config if provided
CUSTOM_CONFIG_SRC="$(dirname "${BASH_SOURCE[0]}")/config.jsonc"
if [ -f "$CUSTOM_CONFIG_SRC" ]; then
  log "Copying custom Fastfetch config..."
  cp -f "$CUSTOM_CONFIG_SRC" "$FASTFETCH_CONFIG_DIR/config.jsonc"
else
  log "Custom Fastfetch config not found – using generated config."
fi

# --------------------------
# Helper to add an APT source via /etc/apt/sources.list.d
# --------------------------
add_apt_source() {
  local name="$1"   # short identifier for the repo
  local url="$2"    # base URL for the repo
  local key_url="$3"# URL to the repo GPG key
  local dist="$(lsb_release -cs)"
  local list_file="/etc/apt/sources.list.d/${name}.list"
  if [ -f "$list_file" ]; then
    log "APT source $name already exists – skipping."
    return
  fi
  log "Adding APT source $name..."
  curl -fsSL "$key_url" | gpg --dearmor -o "/usr/share/keyrings/${name}-archive-keyring.gpg"
  echo "deb [signed-by=/usr/share/keyrings/${name}-archive-keyring.gpg] $url $dist main" > "$list_file"
  apt-get update -y
}

# Helper to install a .deb package directly
install_deb() {
  local url="$1"
  local pkg="$(basename "$url")"
  local tmp="/tmp/${pkg}"
  log "Downloading $pkg..."
  wget -qO "$tmp" "$url"
  log "Installing $pkg..."
  dpkg -i "$tmp" || apt-get install -f -y
  rm -f "$tmp"
}

# --------------------------
# Install Applications
# --------------------------
# Brave Browser (official repo)
add_apt_source "brave" "https://brave-browser-apt-release.s3.brave.com/" "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
apt-get install -y brave-browser

# Visual Studio Code (Microsoft repo)
add_apt_source "vscode" "https://packages.microsoft.com/repos/vscode" "https://packages.microsoft.com/keys/microsoft.asc"
apt-get install -y code

# Docker Engine (official repo)
add_apt_source "docker" "https://download.docker.com/linux/ubuntu" "https://download.docker.com/linux/ubuntu/gpg"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ghostty – fetch latest .deb from GitHub releases
GHOSTTY_URL=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest |
               grep -E 'browser_download_url.*deb' |
               head -n1 |
               cut -d '"' -f4)
if [ -n "$GHOSTTY_URL" ]; then
  install_deb "$GHOSTTY_URL"
else
  log "Could not locate latest Ghostty .deb – skipping."
fi

# GParted (available in default repos)
apt-get install -y gparted

# --------------------------
# Zsh & Oh‑My‑Zsh Setup (for GNOME Terminal)
# --------------------------
log "Installing Zsh..."
apt-get install -y zsh

# Non‑interactive Oh‑My‑Zsh installation
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing Oh‑My‑Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Copy custom .zshrc if it exists next to this script
ZSHRC_SRC="$(dirname "${BASH_SOURCE[0]}")/.zshrc"
if [ -f "$ZSHRC_SRC" ]; then
  log "Copying custom .zshrc..."
  cp -f "$ZSHRC_SRC" "$HOME/.zshrc"
else
  log "Custom .zshrc not found – leaving existing configuration unchanged."
fi

# Set GNOME Terminal default shell to Zsh (per‑user basis)
log "Setting GNOME Terminal default shell to Zsh for the invoking user..."
sudo -u "${SUDO_USER:-$USER}" dbus-launch gsettings set org.gnome.Terminal.Legacy.Settings default-shell "$(which zsh)"

# --------------------------
# Bash Setup for Ghostty
# --------------------------
BASHRC_SRC="$(dirname "${BASH_SOURCE[0]}")/.bashrc"
if [ -f "$BASHRC_SRC" ]; then
  log "Copying custom .bashrc for Ghostty..."
  cp -f "$BASHRC_SRC" "$HOME/.bashrc"
else
  log "Custom .bashrc not found – leaving existing configuration unchanged."
fi

# Ensure Ghostty uses Bash as its login shell (for the invoking user)
log "Ensuring Ghostty uses Bash as the default login shell..."
sudo -u "${SUDO_USER:-$USER}" chsh -s "$(which bash)" "${SUDO_USER:-$USER}"

# --------------------------
# Final Message
# --------------------------
log "Setup complete!"
log "Please restart your terminal sessions (GNOME Terminal and Ghostty) to apply the new shell configurations."

# Show installed version summary (optional, non‑blocking)
log "Installed versions summary:"
if command -v git >/dev/null; then echo "Git: $(git --version)"; fi
if command -v zsh >/dev/null; then echo "Zsh: $(zsh --version)"; fi
if command -v code >/dev/null; then echo "VS Code: $(code --version)"; fi
if command -v brave-browser >/dev/null; then echo "Brave: $(brave-browser --version)"; fi
if command -v docker >/dev/null; then echo "Docker: $(docker --version)"; fi
if command -v ghostty >/dev/null; then echo "Ghostty: $(ghostty --version)"; fi
