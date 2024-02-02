local nls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local nlsb = nls.builtins

nls.setup({
	sources = {
		-- diagnostics
		-- nlsb.diagnostics.protolint,
		--	nlsb.diagnostics.tsc,
		-- formatters
		nlsb.diagnostics.eslint_d.with({
			filetypes = { "javascript", "typescript", "jsx", "tsx", "react", "html", "css" },
			condition = function()
				return nls.utils.root_pattern(
					"eslint.config.js",
					-- https://eslint.org/docs/user-guide/configuring/configuration-files#configuration-file-formats
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.yaml",
					".eslintrc.yml",
					".eslintrc.json",
					"package.json"
				)(vim.api.nvim_buf_get_name(0)) ~= nil
			end,
		}),
		nlsb.formatting.sqlfluff.with({
			extra_args = { "--dialect", "mysql" },
		}),
		nlsb.formatting.golines.with({
			extra_args = { "-m", "82" },
		}),
		nlsb.formatting.stylua,
		nlsb.formatting.prettierd.with({
			filetypes = {
				"html",
				"css",
				"json",
				"yaml",
				"svelte",
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"jsx",
				"tsx",
				"graphql",
				"graphqls",
			},
		}),
		nlsb.formatting.rustfmt,
		nlsb.formatting.zigfmt,
		nlsb.formatting.markdownlint,
		nlsb.formatting.shfmt,
		nlsb.formatting.black.with({
			extra_args = { "--line-length", "82" },
		}),
		nlsb.formatting.xmlformat,
	},
	-- format on save
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.format({ async = false })
					--vim.lsp.buf.formatting_sync()
				end,
			})
		end
	end,
})
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
