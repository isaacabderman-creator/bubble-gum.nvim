return {
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
			"williamboman/mason.nvim",
		},
		ft = { "java" },
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rcasia/neotest-java",
			"mfussenegger/nvim-dap",
		},
		opts = function()
			return {
				adapters = {
					require("neotest-java")({
						incremental_build = true,
						jvm_args = { "-Xmx512m" },
						junit_jar = vim.fs.joinpath(vim.fn.stdpath("data"), "neotest-java", "junit-platform-console-standalone.jar"),
						test_classname_patterns = { "^.*Tests?$", "^.*IT$", "^.*Spec$", "^.*Check$", "^Test.*$" },
					}),
				},
				output = { open_on_run = false },
				summary = { animated = true },
			}
		end,
		-- Neotest-Java requires a compiled project (mvn compile test-compile) and an attached JDTLS client.
		keys = {
			{
				"<leader>tr",
				function()
					if not vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })[1] then
						vim.notify("JDTLS not attached, cannot run tests", vim.log.levels.ERROR)
						return
					end
					require("neotest").run.run()
				end,
				silent = true,
				desc = "Run Nearest Test",
			},
			{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, silent = true, desc = "Debug Nearest Test" },
			{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, silent = true, desc = "Run Current File" },
			{ "<leader>ts", function() require("neotest").summary.toggle() end, silent = true, desc = "Toggle Test Summary Panel" },
			{ "<leader>to", function() require("neotest").output_panel.toggle() end, silent = true, desc = "Toggle Test Output Panel" },
		},
	},
}
