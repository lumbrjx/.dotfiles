-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true
require("colorizer").setup()
require("nvim-web-devicons").setup({
	override = {
		go = {
			icon = "󰟓",
			color = "#519aba",
			cterm_color = "74",
			name = "Go",
		},

		["node_modules"] = {
			icon = "",
			color = "#8CC84B",
			cterm_color = "197",
			name = "NodeModules",
		},
		["package.json"] = {
			icon = "󰎙",
			color = "#8CC84B",
			cterm_color = "197",
			name = "PackageJson",
		},
		["package-lock.json"] = {
			icon = "󰎙",
			color = "#6b9740",
			cterm_color = "52",
			name = "PackageLockJson",
		},

		["svelte.config.js"] = {
			icon = "󱎔",
			color = "#ff3e00",
			cterm_color = "196",
			name = "SvelteConfig",
		},

		["tsconfig.json"] = {
			icon = "",
			color = "#519aba",
			cterm_color = "74",
			name = "TSConfig",
		},
	},

	default = false,
	color_icons = true,
})
require("nvim-tree").setup({
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 25,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		git_ignored = false,
		dotfiles = false,
		git_clean = false,
		no_buffer = false,
		no_bookmark = false,
		custom = { ".git" },
		exclude = {},
	},
})

vim.keymap.set("n", "<c-n>", ":NvimTreeFindFileToggle<CR>")
