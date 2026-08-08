vim.filetype.add({
  pattern = {
    ["openapi.*%.ya?ml"] = "yaml.openapi",
    ["openapi.*%.json"] = "json.openapi",
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        vacuum = {},
        sourcekit = {
          cmd = {
            "sourcekit-lsp",
          },

          filetypes = {
            "swift",
            "objective-c",
            "objective-cpp",
          },

          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)

            local root = vim.fs.root(bufnr, {
              "Package.swift",
              ".git",
              "*.xcodeproj",
              "*.xcworkspace",
            })

            if root then
              on_dir(root)
            end
          end,
        },
      },
    },
  },
}
