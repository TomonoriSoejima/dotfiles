#!/bin/bash
# Essential aliases only

# Navigation shortcuts
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

# File operations
alias ll="ls -ltrh"
alias o='open .'
alias less="less -NX -i"

# Tool enhancements
alias sed="gsed"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias zip="zip -9"

# Shortcuts
alias down="open ~/Downloads"
alias cdown="cd ~/Downloads"

# Terminal tab title
title() {
  if [ -z "$1" ]; then
    printf "\033]0;%s\007" "$(pwd)"
  else
    printf "\033]0;%s\007" "$1"
  fi
}
