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

# Resolve the actual invoking user's home directory
# (when run via sudo, HOME is /root which is wrong)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

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
  gnome-shell-extension-manager
  dconf-editor
)
log "Installing essential tools..."
apt-get install -y "${ESSENTIAL_PKGS[@]}"

# --------------------------
# Fastfetch Config Setup
# --------------------------
log "Setting up Fastfetch config..."
FASTFETCH_CONFIG_DIR="$REAL_HOME/.config/fastfetch"
mkdir -p "$FASTFETCH_CONFIG_DIR"

# Generate a default config as the real user first
if command -v fastfetch >/dev/null 2>&1; then
  sudo -u "$REAL_USER" fastfetch --gen-config 2>/dev/null || log "Fastfetch default config generation skipped."
fi

# Copy custom Fastfetch config if provided next to this script
CUSTOM_CONFIG_SRC="$(dirname "${BASH_SOURCE[0]}")/config.jsonc"
if [ -f "$CUSTOM_CONFIG_SRC" ]; then
  log "Copying custom Fastfetch config to $FASTFETCH_CONFIG_DIR/config.jsonc..."
  cp -f "$CUSTOM_CONFIG_SRC" "$FASTFETCH_CONFIG_DIR/config.jsonc"
  chown "$REAL_USER:$REAL_USER" "$FASTFETCH_CONFIG_DIR/config.jsonc"
else
  log "Custom Fastfetch config not found at $CUSTOM_CONFIG_SRC – using generated config."
fi

# Ensure the whole config dir is owned by the real user
chown -R "$REAL_USER:$REAL_USER" "$FASTFETCH_CONFIG_DIR"

# --------------------------
# Install Applications
# --------------------------

# --- Brave Browser (official repo) ---
log "Setting up Brave Browser repository..."
if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
  curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] \
https://brave-browser-apt-release.s3.brave.com/ stable main" \
    > /etc/apt/sources.list.d/brave-browser-release.list
  apt-get update -y
else
  log "Brave repo already exists – skipping."
fi
apt-get install -y brave-browser

# --- Visual Studio Code (Microsoft repo) ---
log "Setting up VS Code repository..."
if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg arch=amd64] \
https://packages.microsoft.com/repos/vscode stable main" \
    > /etc/apt/sources.list.d/vscode.list
  apt-get update -y
else
  log "VS Code repo already exists – skipping."
fi
apt-get install -y code

# --- Docker Engine (official repo) ---
log "Setting up Docker repository..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg arch=$(dpkg --print-architecture)] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
else
  log "Docker repo already exists – skipping."
fi
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the real user to the docker group so they can use docker without sudo
usermod -aG docker "$REAL_USER"
log "Added $REAL_USER to the docker group (re-login required to take effect)."

# --- Ghostty – fetch latest .deb from GitHub releases ---
log "Installing Ghostty..."
GHOSTTY_URL=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest \
               | grep -E 'browser_download_url.*\.deb"' \
               | head -n1 \
               | cut -d '"' -f4)
if [ -n "$GHOSTTY_URL" ]; then
  GHOSTTY_DEB="/tmp/ghostty.deb"
  log "Downloading Ghostty from $GHOSTTY_URL..."
  wget -qO "$GHOSTTY_DEB" "$GHOSTTY_URL"
  dpkg -i "$GHOSTTY_DEB" || apt-get install -f -y
  rm -f "$GHOSTTY_DEB"
else
  log "Could not locate latest Ghostty .deb – skipping."
fi

# --- GParted (available in default repos) ---
apt-get install -y gparted

# --------------------------
# Zsh & Oh‑My‑Zsh Setup (for GNOME Terminal)
# --------------------------
log "Installing Zsh..."
apt-get install -y zsh

# Non‑interactive Oh‑My‑Zsh installation (runs as the real user)
if [ ! -d "$REAL_HOME/.oh-my-zsh" ]; then
  log "Installing Oh‑My‑Zsh..."
  sudo -u "$REAL_USER" env RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Copy custom .zshrc to the real user's home
ZSHRC_SRC="$(dirname "${BASH_SOURCE[0]}")/.zshrc"
if [ -f "$ZSHRC_SRC" ]; then
  log "Copying custom .zshrc to $REAL_HOME/.zshrc..."
  cp -f "$ZSHRC_SRC" "$REAL_HOME/.zshrc"
  chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.zshrc"
else
  log "Custom .zshrc not found – leaving existing configuration unchanged."
fi

# Set Zsh as the login shell for the real user (applies system-wide, including GNOME Terminal)
log "Setting Zsh as the default login shell for $REAL_USER..."
chsh -s "$(which zsh)" "$REAL_USER"

# --------------------------
# Bash Setup for Ghostty
# --------------------------
BASHRC_SRC="$(dirname "${BASH_SOURCE[0]}")/.bashrc"
if [ -f "$BASHRC_SRC" ]; then
  log "Copying custom .bashrc to $REAL_HOME/.bashrc..."
  cp -f "$BASHRC_SRC" "$REAL_HOME/.bashrc"
  chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bashrc"
else
  log "Custom .bashrc not found – leaving existing configuration unchanged."
fi

# --------------------------
# Run Zsh to verify it works
# --------------------------
log "Verifying Zsh installation..."
sudo -u "$REAL_USER" zsh --version && log "Zsh is working correctly." \
  || log "Zsh verification failed – please check your installation."

# --------------------------
# Final Message
# --------------------------
log "Setup complete!"
log "Please log out and back in (or restart your terminal) to apply the new shell and group configurations."

# Show installed version summary (optional, non‑blocking)
log "Installed versions summary:"
if command -v git     >/dev/null; then echo "  Git:        $(git --version)"; fi
if command -v zsh     >/dev/null; then echo "  Zsh:        $(zsh --version)"; fi
if command -v code    >/dev/null; then echo "  VS Code:    $(code --version | head -1)"; fi
if command -v brave-browser >/dev/null; then echo "  Brave:      $(brave-browser --version)"; fi
if command -v docker  >/dev/null; then echo "  Docker:     $(docker --version)"; fi
if command -v ghostty >/dev/null; then echo "  Ghostty:    $(ghostty --version)"; fi
if command -v fastfetch >/dev/null; then echo "  Fastfetch:  $(fastfetch --version)"; fi
