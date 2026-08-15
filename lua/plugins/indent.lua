local colors = require("tmux_colors").colors

return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      vim.api.nvim_set_hl(0, "IblIndent", { fg = colors.surface_variant })
      vim.api.nvim_set_hl(0, "IblScope", { fg = colors.outline })

      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
        exclude = {
          filetypes = { "help", "dashboard", "lazy", "NvimTree", "neo-tree" },
        },
      })
    end,
  },
}
