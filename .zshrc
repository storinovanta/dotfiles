# Local binaries (fd/bat shims, zoxide)
export PATH="$HOME/.local/bin:$PATH"

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

# zoxide (smart cd: `z <partial>` instead of cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf keybindings (ctrl+r history, ctrl+t files, alt+c cd)
for _fzf_init in ~/.fzf.zsh \
                 /usr/share/doc/fzf/examples/key-bindings.zsh \
                 /usr/share/fzf/key-bindings.zsh; do
    [ -f "$_fzf_init" ] && source "$_fzf_init" && break
done
unset _fzf_init
