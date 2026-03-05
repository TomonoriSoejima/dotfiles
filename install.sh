#!/bin/bash
# Install dotfiles by creating symlinks

set -e

echo "Installing dotfiles..."

# Backup existing files
for file in .bash_profile .bashrc .zshrc; do
    if [ -f ~/$file ] && [ ! -L ~/$file ]; then
        echo "Backing up existing ~/$file to ~/${file}.backup"
        mv ~/$file ~/${file}.backup
    fi
done

# Create symlinks
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc

echo "✓ Dotfiles installed!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to ~/.env and add your real API keys:"
echo "   cp ~/dotfiles/.env.example ~/.env"
echo "   vi ~/.env"
echo ""
echo "2. Reload your shell:"
echo "   source ~/.bash_profile"
echo ""
echo "3. Verify functions work:"
echo "   type ess"
echo "   ll"
