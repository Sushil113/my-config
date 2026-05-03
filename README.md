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

### Editor Configuration

- **[settings.json](settings.json)** - VS Code settings
  - Font: FiraCode Nerd Font Mono with ligatures
  - Default formatter: Prettier
  - Terminal font: MesloLGLDZ Nerd Font
  - Custom UI layout: activity bar on top, sidebar on right
  - Various editor enhancements: bracket pair guides, smooth cursor animation, sticky scroll disabled


## Setup

1. Copy configuration files to their respective locations:
   ```bash
   # Alacritty
   cp alacritty.toml ~/.config/alacritty/alacritty.toml
   
   # Starship
   cp starship.toml ~/.config/starship.toml
   
   # VS Code
   cp settings.json ~/.config/Code/User/settings.json  # Linux
   # or
   cp settings.json ~/Library/Application\ Support/Code/User/settings.json  # macOS
   ```

2. Ensure required fonts are installed:
   - MesloLGM Nerd Font Mono
   - MesloLGLDZ Nerd Font
   - FiraCode Nerd Font Mono


## Requirements

- Alacritty terminal emulator
- Starship shell prompt
- VS Code editor
- Git
- Nerd Fonts (for terminal and editor)