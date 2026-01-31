return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go" },
        highlight = { enable = true },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.start({
        name = "gopls",
        cmd = { "gopls" },
        root_dir = vim.fs.root(0, { "go.mod", ".git" }),
      })
    end,
  },
}

