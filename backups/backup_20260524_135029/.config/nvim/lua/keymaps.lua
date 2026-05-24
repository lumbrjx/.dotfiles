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

vim.keymap.set("n", "<C-n>", ":Neotree toggle reveal left filesystem<CR>", {})
vim.keymap.set("n", "<C-f>", ":Neotree toggle float buffers<CR>", {})

vim.keymap.set("n", "<leader>gt", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gy", ":Gitsigns toggle_current_line_blame<CR>", {})
vim.keymap.set('n', '<leader>t', vim.cmd.UndotreeToggle, {})

vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

-- Make sure you have Harpoon2 loaded
local harpoon = require("harpoon")

-- REQUIRED: initialize harpoon
harpoon:setup({})

-- Add a file
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
-- Navigate between files
vim.keymap.set("n", "<leader>1", function() harpoon:list():prev() end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():next() end)

vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
local gen = require("gen")

-- 🔹 Inline prompt: ask for a task and run it
vim.keymap.set("n", "<leader>ai", function()
  local prompt = vim.fn.input("🧠 Prompt: ")
  if prompt == "" then return end
  gen.command(prompt)
end, { desc = "Run inline AI prompt" })

-- 🔹 Visual selection: pass selected code as context
vim.keymap.set("v", "<leader>ai", function()
  local prompt = vim.fn.input("🧠 Prompt for selection: ")
  if prompt == "" then return end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local selection = table.concat(lines, "\n")

  gen.command(prompt .. "\n\nContext:\n" .. selection)
end, { desc = "AI prompt with selection" })
local last_prompt = nil

vim.keymap.set("n", "<leader>aa", function()
  if not last_prompt then
    vim.notify("⚠️ No last prompt", vim.log.levels.WARN)
    return
  end
  gen.command(last_prompt)
end, { desc = "Repeat last AI prompt" })

vim.keymap.set("n", "<leader>ap", function()
  local prompt = vim.fn.input("🧠 Prompt: ")
  if prompt == "" then return end
  last_prompt = prompt
  gen.command(prompt)
end, { desc = "Ask AI prompt" })

local gen = require("gen")

gen.write_to_file = function(prompt, output)
  gen.command(prompt, function(result)
    vim.fn.writefile(vim.split(result, "\n"), output)
    vim.notify("💾 Output written to: " .. output)
  end)
end
vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "Chat with LLM" })
vim.keymap.set("n", "<leader>ci", "<cmd>CodeCompanionInline<cr>", { desc = "Inline edit with LLM" })
