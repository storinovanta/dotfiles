export ZSH="${HOME}/.oh-my-zsh"

# zsh theme
ZSH_THEME="robbyrussell"

# zsh plugins
plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

# User configuration
source /etc/profile.d/ona-secrets.sh

DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
