# Personal Configuration Repository

A collection of personal dotfiles and configuration files for development environment setup.

## Contents

### Terminal & Shell Configuration


- **[.bashrc](.bashrc)** - Bash shell configuration
  - Custom aliases for frequently used commands
  - Custom prompt settings

- **[.zshrc](.zshrc)** - Zsh shell configuration
  - Custom settings and aliases
  - Integrates with Starship prompt

### Editor Configuration

- **[settings.json](settings.json)** - VS Code settings
  - Font: FiraCode Nerd Font Mono with ligatures
  - Default formatter: Prettier
  - Terminal font: MesloLGLDZ Nerd Font
  - Custom UI layout: activity bar on top, sidebar on right
  - Various editor enhancements: bracket pair guides, smooth cursor animation, sticky scroll disabled

### System Utilities

- **[shutdown_menu_zenity.sh](shutdown_menu_zenity.sh)** - Graphical shutdown menu
  - Interactive dialog for shutdown, restart, suspend, hibernate, and logout
  - Built with Zenity for GTK-based desktop environments

### Setup Automation

- **[setup.sh](setup.sh)** - Ubuntu 26.04 LTS setup script
  - Automates installation of essential packages, Brave, VS Code, Docker, and Ghostty
  - Installs Zsh and Oh-My-Zsh
  - Sets up GNOME Terminal to use Zsh and Ghostty to use Bash
  - Automatically deploys Fastfetch, `.zshrc`, and `.bashrc` configurations

### Fastfetch Configuration

- **[config.jsonc](config.jsonc)** - Primary Fastfetch configuration
  - Detailed system information display with hardware modules
  - Software and development tools information
  - Custom formatting and icons for better readability
  - Shows CPU, memory, GPU, storage, OS, and software details
  - The `setup.sh` script automatically generates a Fastfetch config when missing and, if a custom `config.jsonc` is present in the repo, copies it to `$HOME/.config/fastfetch/`.

## Setup

### Automated Setup (Ubuntu 26.04 LTS)

For a fresh Ubuntu installation, you can use the automated setup script which will install necessary packages, configure your shells, and deploy configurations:

```bash
sudo ./setup.sh
```

### Manual Setup

If you prefer to manually install or are on a different OS, copy the configuration files to their respective locations:

   ```bash
   # Alacritty
   # Shell configurations
   cp .bashrc ~/
   cp .zshrc ~/

   # VS Code
   cp settings.json ~/.config/Code/User/settings.json  # Linux
   # or
   cp settings.json ~/Library/Application\ Support/Code/User/settings.json  # macOS

   # Fastfetch
   cp config.jsonc ~/.config/fastfetch/config.jsonc

   # System utilities
   cp shutdown_menu_zenity.sh ~/bin/  # or add to PATH
   chmod +x ~/bin/shutdown_menu_zenity.sh
   ```

2. Ensure required fonts are installed:
   - MesloLGM Nerd Font Mono
   - MesloLGLDZ Nerd Font
   - FiraCode Nerd Font Mono

## Requirements

- Fastfetch system information tool
- Zenity (for GUI dialogs)
- Bash and Zsh shells
- VS Code editor
- Git
- Nerd Fonts (for terminal and editor)
