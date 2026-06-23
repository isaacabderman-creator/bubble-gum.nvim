return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rcasia/neotest-java",
    },
    keys = {
      { "<leader>tf", function()
        require("neotest").run.run(vim.fn.expand("%:p"))
      end, desc = "Run File Tests" },
      { "<leader>tr", function()
        require("neotest").run.run()
      end, desc = "Run Nearest Test" },
      { "<leader>tl", function()
        require("neotest").run.run_last()
      end, desc = "Run Last Test" },
      { "<leader>ts", function()
        require("neotest").summary.toggle()
      end, desc = "Toggle Summary" },
      { "<leader>to", function()
        require("neotest").output_panel.toggle()
      end, desc = "Toggle Output Panel" },
    },
    config = function()
      local colors = require("tmux_colors").colors
      local adapter = require("neotest-java")({
        disable_update_notifications = true,
        test_classname_patterns = {
          "^.*Tests?$",
          "^.*IT$",
          "^.*Spec$",
          "^Test.*$",
        },
      })

      local root_finder = require("neotest-java.core.root_finder")
      local Path = require("neotest-java.model.path")
      local original_is_test_file = adapter.is_test_file
      adapter.is_test_file = function(file_path)
        if original_is_test_file(file_path) then
          return true
        end
        local dir = vim.fn.fnamemodify(file_path, ":h")
        local project_root = root_finder.find_root(dir)
        if not project_root then
          return false
        end
        local p = Path(file_path)
        local rel = p:make_relative(Path(project_root))
        if rel:contains("main") then
          return false
        end
        local stem = p:stem()
        for _, re in ipairs(adapter.config.test_classname_patterns) do
          if stem:match(re) then
            return true
          end
        end
        return false
      end

      require("neotest").setup({
        adapters = { adapter },
        icons = {
          passed = "",
          failed = "",
          running = "",
          skipped = "",
          unknown = "",
          child_indent = "│",
          child_prefix = "├",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          collapsed = "─",
          expanded = "╮",
        },
        highlights = {
          passed = "NeotestPassed",
          failed = "NeotestFailed",
          running = "NeotestRunning",
          skipped = "NeotestSkipped",
          unknown = "NeotestUnknown",
          border = "NeotestBorder",
        },
        status = {
          virtual_text = true,
        },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.WARN,
        },
        output = {
          open_on_run = "short",
        },
        summary = {
          animated = true,
          follow = true,
          expand_errors = true,
          floating = {
            border = "rounded",
            max_height = 0.6,
            max_width = 0.6,
          },
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "E",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u",
          },
        },
      })

      vim.api.nvim_set_hl(0, "NeotestPassed", { fg = colors.success })
      vim.api.nvim_set_hl(0, "NeotestFailed", { fg = colors.error })
      vim.api.nvim_set_hl(0, "NeotestRunning", { fg = colors.info })
      vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = colors.warning })
      vim.api.nvim_set_hl(0, "NeotestUnknown", { fg = colors.on_surface_variant })
      vim.api.nvim_set_hl(0, "NeotestBorder", { fg = colors.outline })
    end,
  },
}
