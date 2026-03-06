# Minimal Modern Dotfiles

Ultra-minimal bash configuration. AI-first approach: keep only what can't be easily recreated.

## Philosophy

- **Minimal**: Only essential functions (ESS diagnostics) and basic aliases
- **AI-First**: Complex operations delegated to AI assistant
- **Modular**: Clean separation of concerns
- **Secure**: API keys in ~/.env (never committed)

## Structure

```
~/dotfiles/
├── .bash_profile          # Sources .bashrc
├── .bashrc                # Sources all modules
├── .zshrc                 # Optional zsh fallback
├── env.sh                 # Environment variables, PATH, history
├── aliases.sh             # Basic aliases (ll, .., grep)
├── functions/
│   └── elastic.sh         # ESS diagnostic functions (ess, diag, diagme, diagme5)
├── .env.example           # Template for API keys
├── install.sh             # Symlink automation
└── README.md              # This file
```

## Installation

### New Computer Setup (Complete Bootstrap)

```bash
# 1. Download and run bootstrap script
curl -fsSL https://raw.githubusercontent.com/TomonoriSoejima/dotfiles/main/bootstrap.sh | bash

# Or clone first, then run
git clone https://github.com/TomonoriSoejima/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

This will:
- Install Xcode Command Line Tools
- Install Homebrew + essential tools (git, gh, jq, tree, bat, etc.)
- Install programming languages (Python, Node.js, Go, Java 17)
- Authenticate with GitHub
- Clone dotfiles + elastic repos (labs, utilities, tools)
- Set up .env template
- Initialize Python virtual environments

### Existing Computer (Dotfiles Only)

```bash
# 1. Clone or create this repo
cd ~/dotfiles

# 2. Run install script
./install.sh

# 3. Copy .env template and add your real API keys
cp .env.example ~/.env
vi ~/.env

# 4. Reload shell
source ~/.bash_profile
```

## What's Included

**Functions:**
- `ess` - ESS API proxy
- `diag` - Download diagnostics
- `diagme` - Download diagnostics with timestamped folder
- `diagme5` - Download diagnostics, wait 5min, re-pull stats

**Aliases:**
- `ll` - ls -ltrh
- `..`, `...`, `.3`, `.4`, `.5`, `.6` - Navigate up directories
- `o` - Open current directory in Finder
- Color-enhanced grep, less, etc.

## What's NOT Included (AI-First Approach)

Dropped functions that can be handled by AI assistant:
- Navigation helpers (gg, g, cu, ses, gcl)
- Docker wrappers (dockbash, dcup)
- Terminal management (title, tabs, jump_tab)
- Utility functions (boon, mappi, task, ana, backup, byte, etc.)

Just ask your AI assistant when you need these operations!

## Updating

```bash
cd ~/dotfiles
git pull
source ~/.bash_profile
```

## Backup

Historical configs archived at:
- Private: https://github.com/TomonoriSoejima/dotfiles-archive
- Public: https://github.com/TomonoriSoejima/dotfiles-archive-public
