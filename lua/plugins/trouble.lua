return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Workspace Diagnostics" },
      { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<leader>xr", "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "References & Definitions" },
      { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix List" },
      { "<leader>xl", "<Cmd>Trouble loclist toggle<CR>", desc = "Location List" },
    },
    opts = {
      focus = true,
      win = { border = "rounded" },
    },
    config = function(_, opts)
      local colors = require("tmux_colors").colors

      require("trouble").setup(opts)

      vim.api.nvim_set_hl(0, "TroubleNormal", { fg = colors.on_surface, bg = colors.surface })
      vim.api.nvim_set_hl(0, "TroubleNormalNC", { fg = colors.on_surface_variant, bg = colors.surface })
      vim.api.nvim_set_hl(0, "TroubleText", { fg = colors.on_surface })
      vim.api.nvim_set_hl(0, "TroubleCount", { fg = colors.on_primary, bg = colors.primary })
      vim.api.nvim_set_hl(0, "TroubleIndent", { fg = colors.outline_variant })
      vim.api.nvim_set_hl(0, "TroublePos", { fg = colors.outline })
      vim.api.nvim_set_hl(0, "TroubleFilename", { fg = colors.primary, bold = true })
    end,
  },
}
