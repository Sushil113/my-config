# Setup Script Documentation

> Detailed reference for [`setup.sh`](./setup.sh) — the automated development environment installer.

---

## Overview

`setup.sh` is an idempotent Bash script that bootstraps a complete development workstation from scratch. It detects your Linux distribution, installs packages using the appropriate package manager, deploys dotfiles, and configures your shell environment — all in a single command.

**Supported Distributions:**

| Distribution       | Package Manager | Notes                              |
| ------------------ | --------------- | ---------------------------------- |
| Ubuntu / Debian    | `apt`           | Fully supported (primary target)   |
| Fedora / RHEL      | `dnf`           | Fully supported                    |
| Arch Linux         | `pacman` / `yay`| AUR helper installed automatically |

> [!NOTE]
> Derivative distributions (e.g., Linux Mint, Pop!_OS, Manjaro) are also detected via `/etc/os-release` and mapped to the correct package manager.

---

## How to Run

### Prerequisites

- A supported Linux distribution (see table above)
- `git` installed (to clone the repository)
- `sudo` access
- Internet connection

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Sushil113/my-config.git
cd my-config

# 2. Make the script executable
chmod +x setup.sh

# 3. Run with sudo
sudo ./setup.sh
```

> [!IMPORTANT]
> **You must log out and log back in** after the script completes. This is required for:
> - Zsh to become your default shell
> - Docker to work without `sudo` (group membership change)

### Post-Setup (Optional)

On first Zsh launch, **Powerlevel10k** will start a configuration wizard. Follow the prompts to pick your preferred terminal theme style.

---

## What the Script Does

The script executes the following steps in order:

### 1. System Update & Upgrade

Updates package lists and upgrades all existing packages to their latest versions.

### 2. Install Essential Packages

Installs core CLI tools and GNOME desktop utilities.

**Common packages** (all distros):

| Package      | Description                           |
| ------------ | ------------------------------------- |
| `curl`       | Command-line HTTP client              |
| `wget`       | File downloader                       |
| `git`        | Version control system                |
| `unzip`      | Archive extraction                    |
| `vim`        | Terminal text editor                  |
| `btop`       | Modern system resource monitor        |
| `fastfetch`  | System information display tool       |
| `gparted`    | Graphical disk partition editor       |
| `zsh`        | Z Shell                              |

**Distro-specific extras:**

| apt (Ubuntu/Debian)                | dnf (Fedora)                    | pacman (Arch)             |
| ---------------------------------- | ------------------------------- | ------------------------- |
| `build-essential`                  | `@development-tools`            | `base-devel`              |
| `software-properties-common`       | `gnome-tweaks`                  | `gnome-tweaks`            |
| `apt-transport-https`              | `gnome-shell-extension-common`  | `gnome-shell-extensions`  |
| `ca-certificates`, `gnupg`         | `gnome-extensions-app`          | `dconf-editor`            |
| `gnome-tweaks`                     | `dconf-editor`                  |                           |
| `gnome-shell-extensions`           |                                 |                           |
| `gnome-shell-extension-manager`    |                                 |                           |
| `dconf-editor`                     |                                 |                           |
| `gnome-browser-connector`          |                                 |                           |

### 3. Configure Fastfetch

- Creates `~/.config/fastfetch/` directory
- Generates a default Fastfetch config
- Copies the custom [`config.jsonc`](./config.jsonc) over the default (if present)

### 4. Install Applications

#### Brave Browser

| Distro         | Method                                |
| -------------- | ------------------------------------- |
| Ubuntu/Debian  | Official APT repository + GPG key     |
| Fedora         | Official DNF repository + RPM key     |
| Arch           | AUR (`brave-bin` via `yay`)           |

#### Visual Studio Code

| Distro         | Method                                |
| -------------- | ------------------------------------- |
| Ubuntu/Debian  | Microsoft APT repository + GPG key    |
| Fedora         | Microsoft YUM repository + RPM key    |
| Arch           | Official repos (`code` — OSS build)  |

#### Docker Engine

| Distro         | Method                                          |
| -------------- | ------------------------------------------------ |
| Ubuntu/Debian  | Docker's official APT repo (auto-detects base)   |
| Fedora         | Docker's official DNF repo                       |
| Arch           | Official repos (`docker`, `docker-compose`)      |

After installation:
- Creates the `docker` group (if it doesn't exist)
- Adds the current user to the `docker` group
- Enables and starts the Docker systemd service

#### Ghostty Terminal

| Distro         | Method                                     |
| -------------- | ------------------------------------------ |
| Ubuntu/Debian  | Installed if available in APT repos        |
| Fedora         | Installed if available in DNF repos        |
| Arch           | Official repos                             |

### 5. Shell Setup (Zsh + Oh-My-Zsh)

- Installs **Oh-My-Zsh** framework (non-interactive, runs as real user)
- Copies the custom [`.zshrc`](./.zshrc) to `~/`
- Sets **Zsh as the default login shell** via `chsh`

### 6. Bash Setup (for Ghostty)

- Copies the custom [`.bashrc`](./.bashrc) to `~/`

### 7. Install Nerd Fonts

Downloads and installs to `/usr/local/share/fonts/`:

| Font                        | Source                                      |
| --------------------------- | ------------------------------------------- |
| **MesloLGLDZ Nerd Font**    | [nerd-fonts/Meslo](https://github.com/ryanoasis/nerd-fonts) |
| **FiraCode Nerd Font Mono** | [nerd-fonts/FiraCode](https://github.com/ryanoasis/nerd-fonts) |

Runs `fc-cache -fv` to rebuild the system font cache after installation.

### 8. Install Zsh Plugins & Theme

Clones into `~/.oh-my-zsh/custom/`:

| Component                    | Repository                                                                 | Location                                  |
| ---------------------------- | -------------------------------------------------------------------------- | ----------------------------------------- |
| **Powerlevel10k**            | [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)          | `~/.oh-my-zsh/custom/themes/powerlevel10k` |
| **zsh-autosuggestions**      | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions` |
| **zsh-syntax-highlighting**  | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting` |

### 9. Version Summary

Prints the installed versions of Git, Zsh, VS Code, Brave, Docker, Ghostty, and Fastfetch.

---

## Files Copied by the Script

The script deploys configuration files from the repository to the user's home directory:

| Source (in repo)                       | Destination                              | Description                        |
| -------------------------------------- | ---------------------------------------- | ---------------------------------- |
| [`.zshrc`](./.zshrc)                   | `~/.zshrc`                               | Zsh shell configuration            |
| [`.bashrc`](./.bashrc)                 | `~/.bashrc`                              | Bash shell configuration           |
| [`config.jsonc`](./config.jsonc)       | `~/.config/fastfetch/config.jsonc`       | Fastfetch display configuration    |

> [!WARNING]
> The script **overwrites** existing `.zshrc` and `.bashrc` files without prompting. Back up your current configs before running:
> ```bash
> cp ~/.bashrc ~/.bashrc.backup
> cp ~/.zshrc ~/.zshrc.backup
> ```

---

## Script Design Notes

- **Idempotent** — Safe to run multiple times. Already-installed packages and existing repos are skipped.
- **Runs as root** — Required for package installation and system-level changes. The script detects the real invoking user via `$SUDO_USER` so dotfiles are deployed with correct ownership.
- **Fail-fast** — Uses `set -euo pipefail` to exit immediately on any error.
- **Distro-aware** — Reads `/etc/os-release` to detect the OS and maps to the correct package manager automatically.

---

## Execution Flow Diagram

```
sudo ./setup.sh
    │
    ├── Detect OS & package manager
    ├── Update & upgrade system
    ├── Install essential packages (curl, git, vim, btop, zsh, ...)
    ├── Configure Fastfetch (copy config.jsonc)
    ├── Install Brave Browser (add repo + install)
    ├── Install VS Code (add repo + install)
    ├── Install Docker Engine (add repo + install + enable service)
    │     └── Add user to docker group
    ├── Install Ghostty terminal
    ├── Install Oh-My-Zsh + copy .zshrc + set Zsh as default shell
    ├── Copy .bashrc (for Ghostty)
    ├── Install Nerd Fonts (Meslo + FiraCode)
    ├── Install Powerlevel10k + Zsh plugins
    └── Print version summary
```
