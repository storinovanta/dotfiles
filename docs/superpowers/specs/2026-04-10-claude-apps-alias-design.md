# claude-apps Alias Design

**Date:** 2026-04-10
**Status:** Approved

## Problem

Starting a Claude session with the access management knowledge base requires four manual steps:
1. Start a Claude session
2. Tell Claude to load the KB (runs the `load-access-kb` skill)
3. Exit the session
4. Restart with `--add-dir` pointing at the cloned KB

This friction discourages using the KB regularly.

## Goal

Make the KB available on every Ona environment automatically, and provide a `claude-apps` alias that launches Claude pre-configured with the KB directory — pulling the latest changes first.

## Design

### 1. `install.sh` — clone KB during environment setup

Add a KB clone/pull step after the `git config --global diff.colorMoved default` block (the last block in the file):

```sh
# --- Clone access-mgmt-knowledge-base ---
KB_DIR="$HOME/access-mgmt-knowledge-base"
if [ -d "$KB_DIR/.git" ]; then
  git -C "$KB_DIR" pull --ff-only --quiet 2>/dev/null || echo "KB: pull failed, using cached version"
else
  git clone https://github.com/VantaInc/access-mgmt-knowledge-base.git "$KB_DIR" \
    || echo "KB: clone failed — run manually later"
fi
```

- Clone failure is soft — logs a warning and continues if git auth isn't ready at install time
- Idempotent: pull if already cloned, clone if not

**Note:** `install.sh` has a misplaced shebang (`#!/bin/bash` on line 2 instead of line 1). This is a pre-existing issue — the script runs under whatever shell invokes it (typically zsh on Ona). The KB clone block uses only POSIX-compatible constructs and is unaffected.

### 2. `.aliases` — `claude-apps` shell function

Add to `.aliases`:

```sh
# claude with access-mgmt knowledge base
claude-apps() {
  local kb="$HOME/access-mgmt-knowledge-base"
  if ! command -v claude >/dev/null 2>&1; then
    echo "claude not found — is Claude Code installed?"
    return 1
  fi
  if [ -d "$kb/.git" ]; then
    git -C "$kb" pull --ff-only --quiet 2>/dev/null || echo "KB: pull failed, using cached version"
  else
    echo "KB not found at $kb — run install.sh first"
    return 1
  fi
  claude --add-dir "$kb" "$@"
}
```

- Shell function (not alias) to allow logic and arg passthrough
- `"$@"` forwards any extra flags (e.g., `claude-apps --model opus`)
- Guards against missing `claude` binary with a clear error message
- Pull is quiet — no noise unless it fails
- Fails fast with a helpful message if KB was never cloned

## What's not changing

- The `load-access-kb` skill still exists for one-off use or non-Ona environments
- No changes to `settings.json` or other Claude config
- No new files outside dotfiles — everything stays in `install.sh` and `.aliases`

## KB location

`$HOME/access-mgmt-knowledge-base` — portable across Ona and macOS.
