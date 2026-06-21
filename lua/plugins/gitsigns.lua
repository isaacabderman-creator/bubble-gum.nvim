return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 200,
        },
      })

      vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle Git Blame" })
    end,
  },
}
