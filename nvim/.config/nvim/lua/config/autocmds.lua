-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.filetype.add({
  extension = {
    puml = "plantuml",
    plantuml = "plantuml",
    pu = "plantuml",
  },
})

vim.api.nvim_create_user_command("PumlPreview", function()
  local file = vim.fn.expand("%")
  local png = vim.fn.expand("%:r") .. ".png"
  vim.fn.system({ "plantuml", file })
  vim.fn.system({ "open", png })
end, {})
