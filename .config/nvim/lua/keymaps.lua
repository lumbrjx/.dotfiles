vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.autowrite = true
vim.opt.autoread = true
vim.opt.showcmd = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.o.undofile = true
vim.g.NERDTreeShowHidden = 1
-- Function to toggle comments based on file type
function ToggleComments()
	local comment_leader = vim.bo.commentstring or ""
	vim.api.nvim_command("silent s@^\\V" .. vim.pesc(comment_leader) .. "@// @e")
	vim.api.nvim_command("nohlsearch")
end

-- Map a key sequence to toggle comments in visual mode
vim.api.nvim_set_keymap("x", "<Leader>c", [[:lua ToggleComments()<CR>]], { noremap = true, silent = true })

-- Map <Leader>s to save the file
vim.api.nvim_set_keymap("n", "<Leader>s", [[:wa!<CR>]], { noremap = true, silent = true })

vim.api.nvim_set_option("clipboard", "unnamed")

vim.keymap.set("n", "<leader>r", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
vim.api.nvim_set_keymap('n', '<leader>p', 'iif err != nil {\n\tlog.Fatalf("Error: %v", err)\n}',
	{ noremap = true, silent = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set("n", "<C-n>", ":Neotree toggle left filesystem<CR>", {})
vim.keymap.set("n", "<C-f>", ":Neotree toggle float buffers<CR>", {})

vim.keymap.set("n", "<leader>gt", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gy", ":Gitsigns toggle_current_line_blame<CR>", {})
vim.keymap.set('n', '<leader>t', vim.cmd.UndotreeToggle, {})
