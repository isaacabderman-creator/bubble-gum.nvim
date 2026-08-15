return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    keys = { "<F5>", "<F9>", "<F10>", "<F11>", "<F12>", "<leader>b" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup()
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      vim.keymap.set("n", "<F5>", dap.continue, { silent = true, desc = "Debugger: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { silent = true, desc = "Debugger: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { silent = true, desc = "Debugger: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { silent = true, desc = "Debugger: Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { silent = true, desc = "Debugger: Toggle Breakpoint" })

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      local function node_configurations(label)
        return {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch" .. label,
            program = "${file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            console = "integratedTerminal",
            outFiles = { "${workspaceFolder}/**/**/*.js" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach" .. label,
            port = 9229,
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            outFiles = { "${workspaceFolder}/**/**/*.js" },
          },
        }
      end

      dap.configurations.javascript = node_configurations("")
      dap.configurations.typescript = node_configurations(" TS")
    end,
  },
}
