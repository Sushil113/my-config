# Personal Configuration Repository

A collection of personal dotfiles and configuration files for development environment setup.

## Contents

### Terminal & Shell Configuration

- **[alacritty.toml](alacritty.toml)** - Alacritty terminal emulator configuration
  - Window dimensions: 120x30
  - Font: MesloLGM Nerd Font Mono (size 13)
  - Theme: Dracula
  - Custom padding and scrollback history (10000 lines)

- **[starship.toml](starship.toml)** - Starship prompt configuration
  - Custom multi-line prompt with module indicators
  - Shows Python, username, directory, git branch/status, programming languages, Docker, and time
  - Color scheme: Nordic theme with custom segment colors

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

### Fastfetch Configuration

- **[config.jsonc](config.jsonc)** - Primary Fastfetch configuration
  - Detailed system information display with hardware modules
  - Software and development tools information
  - Custom formatting and icons for better readability
  - Shows CPU, memory, GPU, storage, OS, and software details

- **[config2.jsonc](config2.jsonc)** - Alternative Fastfetch configuration
  - Streamlined system information display
  - Lightweight variant for quick system checks

## Setup

1. Copy configuration files to their respective locations:

   ```bash
   # Alacritty
   cp alacritty.toml ~/.config/alacritty/alacritty.toml

   # Starship
   cp starship.toml ~/.config/starship.toml

   # Shell configurations
   cp .bashrc ~/
   cp .zshrc ~/

   # VS Code
   cp settings.json ~/.config/Code/User/settings.json  # Linux
   # or
   cp settings.json ~/Library/Application\ Support/Code/User/settings.json  # macOS

   # Fastfetch
   cp config.jsonc ~/.config/fastfetch/config.jsonc
   cp config2.jsonc ~/.config/fastfetch/config2.jsonc

   # System utilities
   cp shutdown_menu_zenity.sh ~/bin/  # or add to PATH
   chmod +x ~/bin/shutdown_menu_zenity.sh
   ```

2. Ensure required fonts are installed:
   - MesloLGM Nerd Font Mono
   - MesloLGLDZ Nerd Font
   - FiraCode Nerd Font Mono

## Requirements

- Alacritty terminal emulator
- Starship shell prompt
- Fastfetch system information tool
- Zenity (for GUI dialogs)
- Bash and Zsh shells
- VS Code editor
- Git
- Nerd Fonts (for terminal and editor)
