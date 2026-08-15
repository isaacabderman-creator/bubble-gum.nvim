return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    -- Loaded on attach rather than on the keymap, so lualine's winbar has
    -- symbol locations to render breadcrumbs from without being pressed first.
    event = "LspAttach",
    keys = {
      { "<leader>a", "<Cmd>AerialToggle!<CR>", desc = "Toggle Symbol Outline" },
      { "[s", "<Cmd>AerialPrev<CR>", desc = "Previous Symbol" },
      { "]s", "<Cmd>AerialNext<CR>", desc = "Next Symbol" },
    },
    config = function()
      local colors = require("tmux_colors").colors

      require("aerial").setup({
        layout = {
          default_direction = "right",
          min_width = 30,
          win_opts = { winhighlight = "Normal:AerialNormal,SignColumn:AerialNormal" },
        },
        attach_mode = "global",
        close_automatic_events = { "unsupported" },
        show_guides = true,
        guides = {
          mid_item = "├─",
          last_item = "╰─",
          nested_top = "│ ",
          whitespace = "  ",
        },
        filter_kind = false,
      })

      vim.api.nvim_set_hl(0, "AerialNormal", { fg = colors.on_surface, bg = colors.surface })
      vim.api.nvim_set_hl(0, "AerialLine", { bg = colors.primary_container, bold = true })
      vim.api.nvim_set_hl(0, "AerialGuide", { fg = colors.outline_variant })
    end,
  },
}
