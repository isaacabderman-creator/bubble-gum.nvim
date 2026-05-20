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
						ignore_wrapper = false,
						incremental_build = true,
						jvm_args = { "-Xmx512m" },
					}),
				},
				output = { open_on_run = false },
				summary = { animated = true },
			}
		end,
		keys = {
			{ "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
			{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest Test" },
			{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run Current File" },
			{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary Panel" },
			{ "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle Test Output Panel" },
		},
	},
}
