local colors = require("tmux_colors").colors

local groups = {
  "RainbowDelimiterRed",
  "RainbowDelimiterOrange",
  "RainbowDelimiterYellow",
  "RainbowDelimiterGreen",
  "RainbowDelimiterCyan",
  "RainbowDelimiterBlue",
  "RainbowDelimiterViolet",
}

local highlights = {
  RainbowDelimiterRed = colors.primary,
  RainbowDelimiterOrange = colors.warning,
  RainbowDelimiterYellow = colors.warning,
  RainbowDelimiterGreen = colors.success,
  RainbowDelimiterCyan = colors.info,
  RainbowDelimiterBlue = colors.secondary,
  RainbowDelimiterViolet = colors.tertiary,
}

return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      for group, fg in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, { fg = fg })
      end

      require("rainbow-delimiters.setup").setup({
        highlight = groups,
      })
    end,
  },
}
