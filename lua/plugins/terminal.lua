return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- No <leader>t* mapping here: that prefix is neotest's.
    keys = { { [[<C-\>]], desc = "Toggle Terminal" } },
    cmd = { "ToggleTerm", "TermExec" },
    config = function()
      local colors = require("tmux_colors").colors

      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        direction = "float",
        shade_terminals = false,
        start_in_insert = true,
        persist_size = true,
        float_opts = {
          border = "rounded",
          winblend = 0,
        },
        highlights = {
          Normal = { guibg = colors.surface },
          NormalFloat = { guibg = colors.surface },
          FloatBorder = { guifg = colors.outline, guibg = colors.surface },
        },
      })
    end,
  },
}
