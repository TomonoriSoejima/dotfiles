#!/bin/bash
# Environment configuration

# PATH configuration
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$PATH:$HOME/scripts/elastic-cloud"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home"

# Go
export GOPATH=/usr/local/go/
export PATH=$PATH:$GOPATH/bin

# Elastic
export ES_TMPDIR=/tmp

# History configuration
export HISTCONTROL=erasedups
export HISTSIZE="1000000"
export HISTIGNORE="&:[ ]*:exit"
shopt -s histappend
export PROMPT_COMMAND='history -a'

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Pager
export PAGER=less
export LESS="-I -G -M -R"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Load API keys from .env (not in git!)
if [ -f ~/.env ]; then
    source ~/.env
fi

# Tool initializations
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Powerline prompt
function _update_ps1() {
    PS1="$(powerline-go -error $?)"
}
PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
