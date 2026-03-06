# Modern minimal bash configuration
# Sources modular configuration files

# Load environment variables and PATH
[ -f ~/dotfiles/env.sh ] && source ~/dotfiles/env.sh

# Load aliases
[ -f ~/dotfiles/aliases.sh ] && source ~/dotfiles/aliases.sh

# Load Elastic Cloud functions
[ -f ~/dotfiles/functions/elastic.sh ] && source ~/dotfiles/functions/elastic.sh

