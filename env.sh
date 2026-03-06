#!/bin/bash
# Environment configuration

# Homebrew (must be early to get correct paths)
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH configuration
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Java - use java_home utility for dynamic version
if [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
fi

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
