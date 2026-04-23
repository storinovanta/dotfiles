# not really needed since I'm not installing additional scripts
#!/bin/bash

# Needed to default to zsh shell when SSH'ing in
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

# --- Install oh-my-zsh (before symlinking .zshrc so our version wins) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks

# --- Install default Claude Code user settings (only if missing) ---
SRC_CLAUDE_SETTINGS="$HOME/dotfiles/.claude/settings.json"
SRC_CLAUDE_MD="$HOME/dotfiles/.claude/CLAUDE.md"
DEST_DIR="$HOME/.claude"
DEST_CLAUDE_SETTINGS="$DEST_DIR/settings.json"
DEST_CLAUDE_MD="$DEST_DIR/CLAUDE.md"

if [ -f "$SRC_CLAUDE_SETTINGS" ]; then
  mkdir -p "$DEST_DIR"
  if [ ! -f "$DEST_CLAUDE_SETTINGS" ]; then
    cp "$SRC_CLAUDE_SETTINGS" "$DEST_CLAUDE_SETTINGS"
  fi
fi

if [ -f "$SRC_CLAUDE_MD" ]; then
  mkdir -p "$DEST_DIR"
  if [ ! -f "$DEST_CLAUDE_MD" ]; then
    cp "$SRC_CLAUDE_MD" "$DEST_CLAUDE_MD"
  fi
fi

# --- Install Claude Code plugins and MCP servers ---
if command -v claude >/dev/null 2>&1; then
  claude mcp add glean_default https://vanta-be.glean.com/mcp/default \
    --transport http \
    --scope user || true

  claude plugin marketplace add obra/superpowers-marketplace
  claude plugin install superpowers@superpowers-marketplace

  claude plugin marketplace add ndom91/open-plan-annotator
  claude plugin install open-plan-annotator@open-plan-annotator

  if command -v rtk >/dev/null 2>&1; then
    rtk init -g || true
  fi

fi

# --- Install oh-my-zsh custom plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
install_omz_plugin() {
    local name=$1 repo=$2
    local dest="$ZSH_CUSTOM/plugins/$name"
    if [ ! -d "$dest" ]; then
        git clone --depth=1 "https://github.com/$repo" "$dest"
    fi
}

install_omz_plugin zsh-autosuggestions          zsh-users/zsh-autosuggestions
install_omz_plugin zsh-syntax-highlighting      zsh-users/zsh-syntax-highlighting
install_omz_plugin zsh-history-substring-search zsh-users/zsh-history-substring-search
install_omz_plugin zsh-completions              zsh-users/zsh-completions

# --- Install CLI tools ---
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ripgrep fd-find fzf bat 2>/dev/null || true

    # Debian/Ubuntu name these differently; create ~/.local/bin shims
    mkdir -p ~/.local/bin
    [ ! -e ~/.local/bin/fd  ] && command -v fdfind  >/dev/null 2>&1 && ln -sf "$(command -v fdfind)"  ~/.local/bin/fd
    [ ! -e ~/.local/bin/bat ] && command -v batcat  >/dev/null 2>&1 && ln -sf "$(command -v batcat)"  ~/.local/bin/bat

    # git-delta (not in standard apt)
    if ! command -v delta >/dev/null 2>&1; then
        DELTA_VER="0.18.2"
        curl -sLo /tmp/delta.deb \
            "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/git-delta_${DELTA_VER}_amd64.deb"
        sudo dpkg -i /tmp/delta.deb && rm /tmp/delta.deb
    fi

    # eza (may not be in older Ubuntu apt)
    if ! command -v eza >/dev/null 2>&1; then
        sudo apt-get install -y -qq eza 2>/dev/null || true
    fi
fi

# zoxide (smart cd — install script works on any Linux)
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# rtk (LLM token reducer — installs to ~/.local/bin)
if ! command -v rtk >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
fi

# --- Configure git to use delta ---
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default
fi

# --- Clone access-mgmt-knowledge-base ---
KB_DIR="$HOME/access-mgmt-knowledge-base"
if [ -d "$KB_DIR/.git" ]; then
  git -C "$KB_DIR" pull --ff-only --quiet 2>/dev/null || echo "KB: pull failed, using cached version"
else
  git clone https://github.com/VantaInc/access-mgmt-knowledge-base.git "$KB_DIR" \
    || echo "KB: clone failed — run manually later"
fi
