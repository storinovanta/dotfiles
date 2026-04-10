# claude-apps Alias Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pre-clone the access management knowledge base during Ona environment setup and provide a `claude-apps` shell function that auto-pulls the KB and launches Claude with `--add-dir`.

**Architecture:** Two small, independent edits to existing dotfiles. `install.sh` gets a KB clone/pull block appended to the end. `.aliases` gets a new `claude-apps` shell function added at the bottom.

**Tech Stack:** Bash/zsh shell scripting, git, Claude Code CLI (`claude --add-dir`)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `install.sh` | Modify — append after last block | Clone or pull KB during environment setup |
| `.aliases` | Modify — append at bottom | Add `claude-apps` function |

---

### Task 1: Add KB clone/pull to `install.sh`

**Files:**
- Modify: `install.sh` — append after `git config --global diff.colorMoved default` block (last block, ends around line 118)

- [ ] **Step 1: Read the file to confirm the insertion point**

  Open `install.sh` and verify the last line of the git-delta config block reads:
  ```sh
  git config --global diff.colorMoved default
  fi
  ```
  Confirm this is the last block in the file.

- [ ] **Step 2: Append the KB clone/pull block**

  Add this block after the closing `fi` of the git-delta config block:

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

- [ ] **Step 3: Verify the edit looks correct**

  Read `install.sh` and confirm:
  - The new block appears after the `fi` that closes the `if command -v delta` block
  - Indentation matches the rest of the file (no leading spaces on top-level lines)
  - No syntax errors visible

- [ ] **Step 4: Commit**

  ```bash
  git add install.sh
  git commit -m "feat: clone access-mgmt-knowledge-base during env setup"
  ```

---

### Task 2: Add `claude-apps` shell function to `.aliases`

**Files:**
- Modify: `.aliases` — append at bottom

- [ ] **Step 1: Append the shell function**

  Add this to the bottom of `.aliases`:

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

- [ ] **Step 2: Verify the edit looks correct**

  Read `.aliases` and confirm:
  - The function appears at the bottom
  - The function body is indented with 2 spaces consistently
  - There is a blank line separating it from the previous alias block

- [ ] **Step 3: Manual smoke test — reload aliases and test error paths**

  In a terminal where `~/.aliases` is symlinked to this repo's `.aliases`, run:

  ```bash
  source ~/.aliases

  # Test: KB missing path (rename temporarily or test with a fake path by editing kb var)
  # Easiest: just confirm the function is defined
  type claude-apps
  ```

  Expected output: `claude-apps is a shell function` (or similar)

- [ ] **Step 4: Manual smoke test — happy path (if KB exists)**

  If `$HOME/access-mgmt-knowledge-base` is already cloned (e.g., after running `install.sh`):

  ```bash
  # dry run: check what would be passed to claude
  # You can temporarily replace the last line with `echo claude --add-dir "$kb" "$@"` to verify
  ```

  If KB is not yet cloned, skip this and rely on `install.sh` running in an Ona environment.

- [ ] **Step 5: Commit**

  ```bash
  git add .aliases
  git commit -m "feat: add claude-apps shell function with KB auto-pull"
  ```

---

### Task 3: Push

- [ ] **Step 1: Confirm both commits look right**

  ```bash
  git log --oneline -3
  git diff origin/main..HEAD --stat
  ```

- [ ] **Step 2: Push to remote**

  Before pushing, confirm: this pushes to `origin/main` of your personal dotfiles repo (not a shared Vanta repo).

  ```bash
  git push
  ```
