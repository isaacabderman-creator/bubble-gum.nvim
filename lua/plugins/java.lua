return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts = opts or {}
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"jdtls",
				"lemminx",
				"java-debug-adapter",
				"java-test",
				"google-java-format",
			})
		end,
	},
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
		},
		opts = function()
			return {
				adapters = {
					require("neotest-java")({
						ignore_wrapper = false,
					}),
				},
			}
		end,
		keys = {
			{ "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
			{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run Current File" },
			{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary Panel" },
			{ "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle Test Output Panel" },
		},
	},
}
