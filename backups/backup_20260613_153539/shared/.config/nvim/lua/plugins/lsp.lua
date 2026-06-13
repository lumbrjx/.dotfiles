return {
  {
    "mason-org/mason.nvim",
    opts = {}
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "tsserver", "gopls", "buf_ls" }, -- added buf_ls
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local flags = { debounce_text_changes = 100 }

    -- List of servers
    local servers = { "lua_ls", "tsserver", "gopls", "buf_ls", "solargraph", "html" }

    for _, lsp in ipairs(servers) do
      vim.lsp.config[lsp].setup({
        capabilities = capabilities,
        flags = flags,
      })
    end

    -- Auto-refresh diagnostics
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      callback = function()
        vim.diagnostic.reset()
        vim.diagnostic.show()
      end,
    })

    -- Keymap to restart LSP quickly
    vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP" })
  end,
}

}

