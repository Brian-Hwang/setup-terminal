#!/usr/bin/env bash
set -euo pipefail
if ! command -v sudo >/dev/null 2>&1; then
  alias sudo=""
fi
PKGS="zsh git curl tmux vim"
if command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y $PKGS
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y $PKGS
else
  echo "Neither dnf nor yum found."
  exit 1
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.config"
for f in .zshrc .p10k.zsh .tmux.conf .vimrc; do
  if [ -f "$SCRIPT_DIR/$f" ]; then
    ln -sf "$SCRIPT_DIR/$f" "$HOME/$f"
  fi
done
if [ -d "$SCRIPT_DIR/config" ]; then
  for item in "$SCRIPT_DIR"/config/*; do
    name="$(basename "$item")"
    ln -sfn "$item" "$HOME/.config/$name"
  done
fi
if command -v zsh >/dev/null 2>&1; then
  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    if command -v chsh >/dev/null 2>&1; then
      chsh -s "$(command -v zsh)" "$USER" || true
    fi
  fi
fi
echo "Done. Start a new terminal or run: exec zsh"