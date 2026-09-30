# Setup fzf, including shell completion and key bindings.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
