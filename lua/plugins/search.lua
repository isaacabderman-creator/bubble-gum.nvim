return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "Search & Replace (Project)",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Search & Replace Word",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "v",
        desc = "Search & Replace Selection",
      },
    },
    opts = {
      headerMaxWidth = 80,
      windowCreationCommand = "botright split",
    },
    config = function(_, opts)
      local colors = require("tmux_colors").colors

      require("grug-far").setup(opts)

      vim.api.nvim_set_hl(0, "GrugFarResultsHeader", { fg = colors.primary, bold = true })
      vim.api.nvim_set_hl(0, "GrugFarResultsPath", { fg = colors.secondary, bold = true })
      vim.api.nvim_set_hl(0, "GrugFarResultsLineNo", { fg = colors.outline })
      vim.api.nvim_set_hl(0, "GrugFarResultsMatch", { fg = colors.on_primary, bg = colors.primary })
      vim.api.nvim_set_hl(0, "GrugFarResultsStats", { fg = colors.on_surface_variant })
      vim.api.nvim_set_hl(0, "GrugFarHelpHeader", { fg = colors.tertiary })
      vim.api.nvim_set_hl(0, "GrugFarHelpHeaderKey", { fg = colors.warning })
    end,
  },
}
