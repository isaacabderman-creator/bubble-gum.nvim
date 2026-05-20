return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("nvim-dap-virtual-text").setup()
			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debugger: Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debugger: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debugger: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debugger: Step Out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debugger: Toggle Breakpoint" })
		end,
	},
}
