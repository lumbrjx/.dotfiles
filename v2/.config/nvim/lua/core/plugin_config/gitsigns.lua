require('gitsigns').setup()
vim.keymap.set("n", "<leader>gt", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gy", ":Gitsigns toggle_current_line_blame<CR>", {})
