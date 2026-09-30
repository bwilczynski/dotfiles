vim.filetype.add({
  extension = {
    puml = "plantuml",
    plantuml = "plantuml",
    pu = "plantuml",
  },
})

-- Render the current diagram to PNG next to it and open the result.
vim.api.nvim_create_user_command("PumlPreview", function()
  if vim.fn.executable("plantuml") == 0 then
    vim.notify("PumlPreview: plantuml is not installed (brew install plantuml)", vim.log.levels.ERROR)
    return
  end
  local file = vim.fn.expand("%")
  local out = vim.fn.system({ "plantuml", file })
  if vim.v.shell_error ~= 0 then
    vim.notify("PumlPreview: " .. out, vim.log.levels.ERROR)
    return
  end
  vim.fn.system({ "open", vim.fn.expand("%:r") .. ".png" })
end, {})

return {
  { "aklt/plantuml-syntax", ft = "plantuml" },
}
