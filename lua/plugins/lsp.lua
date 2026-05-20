-- lua/plugins/lsp.lua
-- Modified to work with blink.cmp:
-- • Removed hrsh7th/cmp-nvim-lsp dependency
-- • Use blink.cmp's LSP capabilities (automatically enables full snippet + completion support)
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = { "stylua", "black", "prettier", "google-java-format", "java-debug-adapter", "java-test" },
				},
			},
		},

		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "svelte", "html", "cssls", "jdtls", "ts_ls", "jsonls", "emmet_language_server" },
			})

			-- blink.cmp capabilities (replaces the old cmp_nvim_lsp)
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.api.nvim_create_autocmd("User", {
				pattern = "MasonToolsStartingInstall",
				callback = function()
					vim.schedule(function()
						print("mason-tool-installer is starting")
					end)
				end,
			})

			-- Define LSP configs with blink capabilities
			vim.lsp.config("html", {
				capabilities = capabilities,
			})

			vim.lsp.config("svelte", {
				capabilities = capabilities,
				root_markers = { "svelte.config.js", "package.json", ".git" },
			})

			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				root_markers = { ".git", "pyproject.toml" },
				capabilities = capabilities,
			})

			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				root_markers = { ".git", "lua" },
				capabilities = capabilities,
			})

			vim.lsp.config("emmet_language_server", {
				capabilities = capabilities,
				filetypes = { "html", "css" },
			})

			-- Enable all servers
			vim.lsp.enable({ "lua_ls", "pyright", "svelte", "html", "cssls", "ts_ls", "jsonls", "emmet_language_server" })
		end,
	},
}
