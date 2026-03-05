# not really needed since I'm not installing additional scripts
#!/bin/bash

# Needed to default to zsh shell when SSH'ing in
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

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
fi
