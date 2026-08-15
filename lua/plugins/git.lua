-- Git UI. Neogit rather than a lazygit terminal, since lazygit isn't installed
-- on this machine and Neogit needs no external binary.
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit", "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gg", "<Cmd>Neogit<CR>", desc = "Open Neogit" },
      { "<leader>gc", "<Cmd>Neogit commit<CR>", desc = "Commit" },
      { "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Diff View" },
      { "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "File History" },
    },
    opts = {
      graph_style = "unicode",
      integrations = {
        telescope = true,
        diffview = true,
      },
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
    config = function(_, opts)
      local colors = require("tmux_colors").colors

      require("neogit").setup(opts)

      vim.api.nvim_set_hl(0, "NeogitBranch", { fg = colors.primary, bold = true })
      vim.api.nvim_set_hl(0, "NeogitRemote", { fg = colors.tertiary, bold = true })
      vim.api.nvim_set_hl(0, "NeogitHunkHeader", { fg = colors.on_surface, bg = colors.surface_variant })
      vim.api.nvim_set_hl(
        0,
        "NeogitHunkHeaderHighlight",
        { fg = colors.primary, bg = colors.surface_variant, bold = true }
      )
      vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = colors.success })
      vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = colors.error })
      vim.api.nvim_set_hl(0, "NeogitSectionHeader", { fg = colors.warning, bold = true })
    end,
  },
}
