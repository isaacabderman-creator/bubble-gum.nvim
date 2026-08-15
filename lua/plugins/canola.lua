return {
  "barrettruth/canola.nvim",
  branch = "canola",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.g.canola = {
      columns = { "icon" },
      extglob = true,
      hidden = { enabled = false },
      delete_to_trash = true,
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
    }
  end,
}
