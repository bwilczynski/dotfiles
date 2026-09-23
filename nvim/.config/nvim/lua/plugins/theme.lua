-- The active theme supplies both the colorscheme plugin and the colorscheme
-- name. See the `theme` stow package. Without it, LazyVim's default is used.
local spec = vim.fn.expand("~/.config/theme/current/neovim.lua")

if (vim.uv or vim.loop).fs_stat(spec) then
  return dofile(spec)
end

return {}
