#!/usr/bin/env bash

# =============================================================
# Development Environment Setup Script
# -------------------------------------------------------------
# This script installs a curated list of development tools, utilities,
# and user-requested applications. It also configures the default
# GNOME Terminal to use Zsh (with a provided .zshrc) and Ghostty to use
# Bash (with a provided .bashrc).
#
# Supported Distributions: Ubuntu/Debian, Fedora, Arch Linux
#
# The script is designed to be idempotent – running it repeatedly will
# only install missing packages or skip already-present configuration.
# =============================================================

set -euo pipefail
IFS=$'\n\t'

# --------------------------
# Helper Functions
# --------------------------
log() { echo -e "\e[1;34m[+] $*\e[0m"; }
warn() { echo -e "\e[1;33m[!] $*\e[0m"; }
error() { echo -e "\e[1;31m[!] $*\e[0m" >&2; exit 1; }

# Ensure script runs with root privileges
if [ "$(id -u)" -ne 0 ]; then
	error "Please run this script with sudo or as root."
fi

# Resolve the actual invoking user's home directory
# (when run via sudo, HOME is /root which is wrong)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# --------------------------
# OS Detection
# --------------------------
if [ -f /etc/os-release ]; then
	. /etc/os-release
	OS=$ID
	OS_LIKE=${ID_LIKE:-""}
else
	error "Cannot detect OS distribution. /etc/os-release not found."
fi

# Normalize OS to determine package manager
if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$OS_LIKE" == *"ubuntu"* || "$OS_LIKE" == *"debian"* ]]; then
	PKG_MGR="apt"
elif [[ "$OS" == "fedora" || "$OS_LIKE" == *"fedora"* || "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"centos"* ]]; then
	PKG_MGR="dnf"
elif [[ "$OS" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
	PKG_MGR="pacman"
else
	error "Unsupported OS: $OS. This script supports Ubuntu/Debian, Fedora, and Arch Linux."
fi

log "Detected OS: $OS (Package Manager: $PKG_MGR)"

# --------------------------
# Package Manager Abstraction
# --------------------------
update_system() {
	log "Updating package lists and upgrading system..."
	case "$PKG_MGR" in
		apt) apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y ;;
		dnf) dnf upgrade -y ;;
		pacman) pacman -Syu --noconfirm ;;
	esac
}

install_pkg() {
	case "$PKG_MGR" in
		apt) DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ;;
		dnf) dnf install -y "$@" ;;
		pacman) pacman -S --needed --noconfirm "$@" ;;
	esac
}

install_aur() {
	if [[ "$PKG_MGR" != "pacman" ]]; then return; fi
	# Check for yay
	if ! command -v yay >/dev/null 2>&1; then
		log "Installing yay (AUR helper)..."
		install_pkg git base-devel
		sudo -u "$REAL_USER" bash -c "cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"
	fi
	sudo -u "$REAL_USER" yay -S --needed --noconfirm "$@"
}

# --------------------------
# Update System
# --------------------------
update_system

# --------------------------
# Install Essential Packages
# --------------------------
log "Installing essential tools..."

COMMON_PKGS=(
	curl
	wget
	git
	unzip
	vim
	btop
	fastfetch
	gparted
	zsh
)

case "$PKG_MGR" in
	apt)
		install_pkg "${COMMON_PKGS[@]}" build-essential software-properties-common apt-transport-https ca-certificates gnupg gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager dconf-editor gnome-browser-connector
		;;
	dnf)
		install_pkg "${COMMON_PKGS[@]}" @development-tools gnome-tweaks gnome-shell-extension-common gnome-extensions-app dconf-editor
		;;
	pacman)
		install_pkg "${COMMON_PKGS[@]}" base-devel gnome-tweaks gnome-shell-extensions dconf-editor
		;;
esac

# --------------------------
# Fastfetch Config Setup
# --------------------------
log "Setting up Fastfetch config..."
FASTFETCH_CONFIG_DIR="$REAL_HOME/.config/fastfetch"

# Ensure ~/.config exists and is owned by the real user before creating fastfetch dir
if [ ! -d "$REAL_HOME/.config" ]; then
	sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config"
fi
sudo -u "$REAL_USER" mkdir -p "$FASTFETCH_CONFIG_DIR"

# Generate a default config as the real user first
if command -v fastfetch >/dev/null 2>&1; then
	sudo -u "$REAL_USER" fastfetch --gen-config-force 2>/dev/null || log "Fastfetch default config generation skipped."
fi

# Copy custom Fastfetch config if provided next to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CUSTOM_CONFIG_SRC="$SCRIPT_DIR/config.jsonc"

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

# --- Brave Browser ---
log "Setting up Brave Browser repository..."
case "$PKG_MGR" in
	apt)
		if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
			curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor --yes -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" >/etc/apt/sources.list.d/brave-browser-release.list
			apt-get update -y
		else
			log "Brave repo already exists – skipping."
		fi
		install_pkg brave-browser
		;;
	dnf)
		if [ ! -f /etc/yum.repos.d/brave-browser.repo ]; then
			dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
			rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
		else
			log "Brave repo already exists – skipping."
		fi
		install_pkg brave-browser
		;;
	pacman)
		install_aur brave-bin
		;;
esac

# --- Visual Studio Code ---
log "Setting up VS Code repository..."
case "$PKG_MGR" in
	apt)
		if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
			curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o /usr/share/keyrings/microsoft-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >/etc/apt/sources.list.d/vscode.list
			apt-get update -y
		else
			log "VS Code repo already exists – skipping."
		fi
		install_pkg code
		;;
	dnf)
		if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
			rpm --import https://packages.microsoft.com/keys/microsoft.asc
			echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
		else
			log "VS Code repo already exists – skipping."
		fi
		install_pkg code
		;;
	pacman)
		# Install from official repos (OSS build)
		install_pkg code
		;;
esac

# --- Docker Engine ---
log "Setting up Docker repository..."
case "$PKG_MGR" in
	apt)
		# Determine base distro for Docker repo (derivatives like Mint → ubuntu/debian)
		if [[ "$OS" == "ubuntu" || "$OS_LIKE" == *"ubuntu"* ]]; then
			DOCKER_DISTRO="ubuntu"
		else
			DOCKER_DISTRO="debian"
		fi
		if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
			curl -fsSL "https://download.docker.com/linux/$DOCKER_DISTRO/gpg" | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$DOCKER_DISTRO $VERSION_CODENAME stable" >/etc/apt/sources.list.d/docker.list
			apt-get update -y
		else
			log "Docker repo already exists – skipping."
		fi
		install_pkg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
		;;
	dnf)
		if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
			dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
		else
			log "Docker repo already exists – skipping."
		fi
		install_pkg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
		;;
	pacman)
		install_pkg docker docker-compose
		;;
esac

# Add the real user to the docker group so they can use docker without sudo
if ! getent group docker > /dev/null; then
	groupadd docker
fi
usermod -aG docker "$REAL_USER"
log "Added $REAL_USER to the docker group (re-login required to take effect)."

# Enable docker service if available (systemd)
if command -v systemctl >/dev/null 2>&1; then
	systemctl enable --now docker || warn "Failed to enable docker service."
fi

# --- Ghostty ---
log "Installing Ghostty..."
case "$PKG_MGR" in
	apt)
		if apt-cache show ghostty >/dev/null 2>&1; then
			install_pkg ghostty
		else
			warn "Ghostty package not available in configured APT repositories."
		fi
		;;
	dnf)
		if dnf info ghostty >/dev/null 2>&1; then
			install_pkg ghostty
		else
			warn "Ghostty package not available in DNF repositories."
		fi
		;;
	pacman)
		install_pkg ghostty
		;;
esac

# --------------------------
# Zsh & Oh-My-Zsh Setup
# --------------------------
# Non-interactive Oh-My-Zsh installation (runs as the real user)
if [ ! -d "$REAL_HOME/.oh-my-zsh" ]; then
	log "Installing Oh-My-Zsh..."
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
		| sudo -u "$REAL_USER" env RUNZSH=no KEEP_ZSHRC=yes sh
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

# Set Zsh as the login shell for the real user
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
# Verify Zsh
# --------------------------
log "Verifying Zsh installation..."
sudo -u "$REAL_USER" zsh --version && log "Zsh is working correctly." || log "Zsh verification failed – please check your installation."

# --------------------------
# Install Nerd Fonts
# --------------------------
log "Installing Nerd Fonts..."

FONT_DIR="/usr/local/share/fonts"
mkdir -p "$FONT_DIR"

wget -qO /tmp/Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
unzip -o /tmp/Meslo.zip -d "$FONT_DIR" >/dev/null

wget -qO /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip -o /tmp/FiraCode.zip -d "$FONT_DIR" >/dev/null

fc-cache -fv >/dev/null
rm -f /tmp/Meslo.zip /tmp/FiraCode.zip

log "Nerd Fonts installed successfully."

# --------------------------
# Install Powerlevel10k & Zsh Plugins
# --------------------------
log "Installing Powerlevel10k and Zsh plugins..."

OH_MY_ZSH_CUSTOM="$REAL_HOME/.oh-my-zsh/custom"

# Powerlevel10k theme
if [ ! -d "$OH_MY_ZSH_CUSTOM/themes/powerlevel10k" ]; then
	sudo -u "$REAL_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OH_MY_ZSH_CUSTOM/themes/powerlevel10k"
fi

# zsh-autosuggestions
if [ ! -d "$OH_MY_ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
	sudo -u "$REAL_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$OH_MY_ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$OH_MY_ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
	sudo -u "$REAL_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$OH_MY_ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

log "Powerlevel10k and Zsh plugins installed successfully."

# --------------------------
# Final Message
# --------------------------
log "Setup complete!"
log "Please log out and back in (or restart your terminal) to apply the new shell and group configurations."

# Show installed version summary
log "Installed versions summary:"
if command -v git >/dev/null; then echo "  Git:        $(git --version)"; fi
if command -v zsh >/dev/null; then echo "  Zsh:        $(zsh --version)"; fi
if command -v code >/dev/null; then echo "  VS Code:    $(code --version | head -1)"; fi
if command -v brave-browser >/dev/null; then echo "  Brave:      $(brave-browser --version)"; fi
if command -v docker >/dev/null; then echo "  Docker:     $(docker --version)"; fi
if command -v ghostty >/dev/null; then echo "  Ghostty:    $(ghostty --version)"; fi
if command -v fastfetch >/dev/null; then echo "  Fastfetch:  $(fastfetch --version)"; fi
