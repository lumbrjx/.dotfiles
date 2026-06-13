return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "gopls" },
      })

      local lspconfig = require("lspconfig")

      lspconfig.gopls.setup({
        root_dir = require("lspconfig.util").root_pattern("go.mod", ".git"),
      })
    end,
  },
}
