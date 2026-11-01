-- Point markdownlint-cli2 at a relaxed global ruleset (.markdownlint.yaml in
-- this config dir), unless the file sits in a project with its own config.
local global_config = vim.fn.stdpath("config") .. "/.markdownlint.yaml"

local project_configs = {
  ".markdownlint-cli2.jsonc",
  ".markdownlint-cli2.yaml",
  ".markdownlint-cli2.cjs",
  ".markdownlint-cli2.mjs",
  ".markdownlint.jsonc",
  ".markdownlint.json",
  ".markdownlint.yaml",
  ".markdownlint.yml",
  ".markdownlint.cjs",
  ".markdownlint.mjs",
}

local function config_args(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or 0)
  local found = vim.fs.find(project_configs, { path = vim.fs.dirname(path), upward = true })[1]
  if found and found ~= global_config then
    return {}
  end
  return { "--config", global_config }
end

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function()
      local lint = require("lint")
      local linter = lint.linters["markdownlint-cli2"]
      -- A function linter is resolved per run, so the args follow the buffer.
      lint.linters["markdownlint-cli2"] = function()
        local l = vim.deepcopy(linter)
        l.args = vim.list_extend(config_args(0), { "-" })
        return l
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = function(_, ctx)
            return config_args(ctx.buf)
          end,
        },
      },
    },
  },
}
