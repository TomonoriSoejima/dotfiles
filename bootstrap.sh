#!/bin/bash
# Bootstrap script for new computer setup
# Run this after installing macOS

set -e

echo "🚀 Bootstrapping new computer..."
echo ""

# 1. Install Xcode Command Line Tools
echo "📦 Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "⏸️  Wait for Xcode installation to complete, then run this script again"
    exit 0
else
    echo "✓ Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
echo ""
echo "🍺 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✓ Homebrew already installed"
fi

# 3. Install essential tools via Homebrew
echo ""
echo "🔧 Installing essential tools..."
brew install \
    git \
    gh \
    jq \
    tree \
    bat \
    coreutils \
    colordiff \
    awscli \
    azure-cli

# 4. Install programming languages
echo ""
echo "💻 Installing programming languages..."
brew install \
    python@3.11 \
    node \
    go \
    openjdk@17

# Link Java
echo ""
echo "☕ Setting up Java..."
sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk || true

# 5. Authenticate with GitHub
echo ""
echo "🔐 Authenticating with GitHub..."
if ! gh auth status &> /dev/null; then
    gh auth login
else
    echo "✓ Already authenticated with GitHub"
fi

# 6. Clone essential repositories
echo ""
echo "📂 Cloning repositories..."
cd ~

# Clone dotfiles first
if [ ! -d ~/dotfiles ]; then
    gh repo clone TomonoriSoejima/dotfiles
    cd ~/dotfiles
    ./install.sh
    echo "✓ Dotfiles installed"
else
    echo "✓ Dotfiles already exists"
fi

# Create elastic directory
mkdir -p ~/elastic
cd ~/elastic

# Clone elastic repositories
for repo in elastic-labs elastic-utilities elastic-tools; do
    if [ ! -d ~/elastic/${repo##*-} ]; then
        gh repo clone TomonoriSoejima/$repo ${repo##*-}
        echo "✓ Cloned $repo"
    else
        echo "✓ $repo already exists"
    fi
done

# 7. Set up environment
echo ""
echo "🌍 Setting up environment..."
if [ ! -f ~/.env ]; then
    cp ~/dotfiles/.env.example ~/.env
    echo "⚠️  Edit ~/.env and add your API keys:"
    echo "   - ELASTIC_CLOUD_API_KEY"
    echo "   - GITHUB_TOKEN"
    echo "   - OPENAI_API_KEY (if needed)"
else
    echo "✓ ~/.env already exists"
fi

# 8. Optional: Install Python virtual environments
echo ""
echo "🐍 Setting up Python utilities..."
cd ~/elastic/utilities
for dir in */; do
    if [ -f "$dir/requirements.txt" ]; then
        echo "  Setting up ${dir%/}..."
        cd "$dir"
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -q -r requirements.txt
        deactivate
        cd ..
    fi
done

# 9. Final instructions
echo ""
echo "✅ Bootstrap complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit ~/.env with your API keys:"
echo "   vi ~/.env"
echo ""
echo "2. Reload your shell:"
echo "   source ~/.bash_profile"
echo ""
echo "3. Install VS Code extensions:"
echo "   - GitHub Copilot"
echo "   - GitHub Copilot Chat"
echo ""
echo "4. Verify setup:"
echo "   cd ~/elastic/labs && ls"
echo "   cd ~/elastic/utilities && ls"
echo "   cd ~/elastic/tools && ls"
echo "   type ess"
echo ""
echo "🎉 Happy coding!"
