# My Config — Personal Development Environment

> One-command setup for a fully configured Ubuntu development workstation.

This repository contains my personal **dotfiles** and **configuration files** along with an automated setup script. It is designed for **Ubuntu 26.04 LTS** and handles everything from installing essential tools to configuring your shell, editor, fonts, and terminal — all in a single command.

---

## Table of Contents

- [What Are Dotfiles?](#what-are-dotfiles)
- [Requirements](#-requirements)
- [What Gets Installed](#-what-gets-installed)
- [Repository Contents](#-repository-contents)
- [Setup](#-setup)
  - [Automated Setup (Recommended)](#automated-setup-recommended)
  - [Manual Setup](#manual-setup)
- [Custom Aliases](#-custom-aliases)
- [Fonts](#-fonts)
- [FAQ](#-faq)
- [License](#-license)

---

## What Are Dotfiles?

If you're new to this: **dotfiles** are configuration files on Linux/macOS whose names start with a dot (`.`), like `.bashrc` or `.zshrc`. They control how your shell, editor, and other tools behave. Keeping them in a Git repository means you can:

- Restore your entire setup on a new machine in minutes
- Track changes over time
- Share your configuration with others

---

## Requirements

Before you begin, make sure you have the following:

| Requirement         | Details                                                        |
| ------------------- | -------------------------------------------------------------- |
| **Operating System** | Ubuntu 26.04 LTS (other Debian-based distros may work)        |
| **Architecture**     | x86_64 (amd64)                                                |
| **Git**              | Needed to clone this repository                                |
| **Internet**         | Required to download packages during setup                     |
| **sudo access**      | The setup script must be run with `sudo`                       |

> [!NOTE]
> The automated setup script is built specifically for **Ubuntu 26.04 LTS**. On other distributions you can still use the config files manually — see [Manual Setup](#manual-setup).

---

## What Gets Installed

The `setup.sh` script installs and configures the following automatically:

### Applications

| Application       | Description                          |
| ----------------- | ------------------------------------ |
| **Brave Browser** | Privacy-focused Chromium browser     |
| **VS Code**       | Microsoft's code editor              |
| **Docker**        | Container engine + Docker Compose    |
| **Ghostty**       | Modern GPU-accelerated terminal      |
| **GParted**       | Disk partition editor                |

### Shell & Terminal

| Component                      | Description                                           |
| ------------------------------ | ----------------------------------------------------- |
| **Zsh**                        | Modern shell (set as default login shell)              |
| **Oh-My-Zsh**                  | Zsh framework for managing config and plugins          |
| **Powerlevel10k**              | Fast, feature-rich Zsh theme                           |
| **zsh-autosuggestions**        | Fish-like autosuggestions for Zsh                      |
| **zsh-syntax-highlighting**    | Syntax highlighting for Zsh commands                   |

### System Utilities

| Tool                  | Description                                    |
| --------------------- | ---------------------------------------------- |
| **curl / wget**       | Command-line file downloaders                  |
| **build-essential**   | C/C++ compiler and development libraries       |
| **vim**               | Terminal text editor                           |
| **btop**              | Modern system resource monitor                 |
| **Fastfetch**         | System information display tool                |
| **GNOME Tweaks**      | Desktop environment customization              |
| **GNOME Extensions**  | Shell extensions + extension manager            |
| **dconf Editor**      | Advanced GNOME settings editor                 |

### Fonts (Nerd Fonts)

| Font                        | Used In         |
| --------------------------- | --------------- |
| **MesloLGLDZ Nerd Font**    | Terminal         |
| **FiraCode Nerd Font Mono** | VS Code editor   |

---

## Repository Contents

Here's what each file in this repository does:

```
my-config/
├── .bashrc                    # Bash shell configuration (used by Ghostty)
├── .zshrc                     # Zsh shell configuration  (used by GNOME Terminal)
├── config.jsonc               # Fastfetch display configuration
├── settings.json              # VS Code editor settings
├── setup.sh                   # Automated setup script (run this first!)
├── shutdown_menu_zenity.sh    # Graphical shutdown/restart/suspend menu
└── README.md                  # This file
```

### File Details

#### `.bashrc` — Bash Shell Config
- Runs Fastfetch on terminal launch (shows system info)
- History search with ↑/↓ arrow keys using partial commands
- Custom aliases for system maintenance and Laravel development
- Color-enabled prompt and command output

#### `.zshrc` — Zsh Shell Config
- Powerlevel10k theme with instant prompt
- Oh-My-Zsh with plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- History search with ↑/↓ arrow keys using partial commands
- System maintenance aliases

#### `config.jsonc` — Fastfetch Config
- Customized system info display with hardware and software details
- Shows CPU, memory, GPU, storage, OS, and developer tool versions
- Custom formatting and icons

#### `settings.json` — VS Code Settings
- **Font**: FiraCode Nerd Font Mono (with ligatures enabled)
- **Terminal Font**: MesloLGLDZ Nerd Font
- **Formatter**: Prettier (default)
- **Layout**: Activity bar on top, sidebar on right
- Bracket pair guides, smooth cursor animation

#### `setup.sh` — Automated Setup Script
- Fully idempotent — safe to run multiple times
- Installs all packages, applications, fonts, and plugins
- Configures Zsh as the default shell
- Deploys all dotfiles to your home directory
- Prints an installed-versions summary at the end

#### `shutdown_menu_zenity.sh` — Power Menu
- GTK-based graphical dialog for shutdown, restart, suspend, hibernate, and logout
- Can be bound to a keyboard shortcut for quick access

---

## Setup

### Automated Setup (Recommended)

This is the fastest way to get up and running. The script handles **everything** for you.

**Step 1 — Clone the repository:**

```bash
git clone https://github.com/Sushil113/my-config.git
cd my-config
```

**Step 2 — Make the setup script executable:**

```bash
chmod +x setup.sh
```

**Step 3 — Run the setup script:**

```bash
sudo ./setup.sh
```

**Step 4 — Log out and log back in** (or restart your terminal) to apply the new shell and Docker group settings.

> [!IMPORTANT]
> You **must** log out and back in after running the script. This is needed for:
> - Zsh to load as your default shell
> - Docker to work without `sudo`

**Step 5 (Optional) — Configure Powerlevel10k:**

On first launch of Zsh, Powerlevel10k will walk you through a configuration wizard. Follow the prompts to customize your terminal theme.

---

### Manual Setup

If you're on a different OS or want to pick and choose individual configs:

**1. Copy shell configurations:**

```bash
cp .bashrc ~/
cp .zshrc ~/
```

**2. Copy VS Code settings:**

```bash
# Linux
cp settings.json ~/.config/Code/User/settings.json

# macOS
cp settings.json ~/Library/Application\ Support/Code/User/settings.json
```

**3. Copy Fastfetch config:**

```bash
mkdir -p ~/.config/fastfetch
cp config.jsonc ~/.config/fastfetch/config.jsonc
```

**4. Set up the shutdown menu (optional):**

```bash
mkdir -p ~/bin
cp shutdown_menu_zenity.sh ~/bin/
chmod +x ~/bin/shutdown_menu_zenity.sh
```

**5. Install Nerd Fonts manually:**


Download and install these from [nerdfonts.com](https://www.nerdfonts.com/font-downloads):
- MesloLGLDZ Nerd Font
- FiraCode Nerd Font Mono

---

## Custom Aliases

Both `.bashrc` and `.zshrc` include shortcut aliases to save you time:

### System Maintenance

| Alias          | Command                                           | Description                       |
| -------------- | ------------------------------------------------- | --------------------------------- |
| `update`       | `sudo apt update && sudo apt upgrade`             | Update & upgrade system packages  |
| `updatenala`   | `sudo nala update && sudo nala upgrade`           | Same, using Nala package manager  |
| `clean`        | `sudo apt autoclean && sudo apt autoremove`       | Remove unused packages            |

### Laravel Development (Bash only)

| Alias          | Command                                                        | Description                    |
| -------------- | -------------------------------------------------------------- | ------------------------------ |
| `serve`        | `php artisan serve`                                            | Start Laravel dev server       |
| `work`         | `php artisan queue:flush && queue:clear && queue:work`         | Reset & start queue worker     |
| `sail`         | Auto-detects `sail` or `vendor/bin/sail`                       | Laravel Sail shortcut          |
| `crd`          | `composer run dev`                                             | Run Composer dev script        |
| `cacheclear`   | `php artisan cache:clear && optimize:clear`                    | Clear all Laravel caches       |
| `formatcode`   | `./vendor/bin/pint --dirty`                                    | Format changed files with Pint |

---

## Fonts

The setup installs **Nerd Fonts**, which provide icons and glyphs used by Powerlevel10k and VS Code. The two font families used are:

- **MesloLGLDZ Nerd Font** — used in the terminal (Ghostty / GNOME Terminal)
- **FiraCode Nerd Font Mono** — used in VS Code (supports ligatures like `=>`, `!==`, `>=`)

If your terminal looks broken or icons are missing, make sure these fonts are installed and selected in your terminal's settings.

---

## FAQ

<details>
<summary><strong>Can I use this on a non-Ubuntu distro?</strong></summary>

The automated script (`setup.sh`) uses `apt` and is designed for Ubuntu 26.04 LTS. You can still copy the individual config files (`.bashrc`, `.zshrc`, `settings.json`, etc.) manually on any Linux or macOS system — see [Manual Setup](#manual-setup).
</details>

<details>
<summary><strong>I ran the script but my shell didn't change to Zsh</strong></summary>

Log out and log back in (or restart your computer). The shell change requires a new login session to take effect.
</details>

<details>
<summary><strong>Docker says "permission denied" — what do I do?</strong></summary>

Log out and back in. The script adds your user to the `docker` group, but this only takes effect after a new login session. You can verify with:
```bash
groups | grep docker
```
</details>

<details>
<summary><strong>How do I customize Powerlevel10k?</strong></summary>

Run `p10k configure` in your terminal to re-launch the configuration wizard at any time.
</details>

<details>
<summary><strong>What if I already have a .bashrc or .zshrc?</strong></summary>

The setup script will **overwrite** your existing files. If you have custom configurations, back them up first:
```bash
cp ~/.bashrc ~/.bashrc.backup
cp ~/.zshrc ~/.zshrc.backup
```
</details>

---