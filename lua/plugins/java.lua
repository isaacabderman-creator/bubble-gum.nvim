return {
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		dependencies = {
			"mfussenegger/nvim-dap",
			"williamboman/mason.nvim",
		},
		config = function()
			local java = require("config.java")
			java.setup_jdtls_support()
			if vim.bo.filetype == "java" then
				java.attach_jdtls(0)
			end
		end,
	},
}
