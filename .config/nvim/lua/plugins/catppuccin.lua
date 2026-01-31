return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Load before everything else
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- or latte, frappe, macchiato
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
