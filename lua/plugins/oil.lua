return {
  "stevearc/oil.nvim",
  -- Optional: Dependencies for icons
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" },
      keymaps = {
        ["<C-h>"] = false, -- Disable if it conflicts with your window nav
        ["<C-l>"] = false,
      },
      view_options = {
        show_hidden = true,
      },
    })
  end,
}
