local colors = require("tmux_colors").colors

return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.starter").setup({
      evaluate_single = false,
      header = "\"In my youth I knew the hardships of the world,\nYet I still aspired to soar above the clouds.\nA journey of cold winds and uncertainty,\nA lone traveler experiences a life of ups and downs.\nA heart of steel forged from countless setbacks,\nA lifetime of effort to forge one sword.\"",

      content = function()
        local starter = require("mini.starter")
        return starter.content.default()
      end,
    })

    require("mini.comment").setup()

    vim.api.nvim_set_hl(0, "MiniStarterHeader", { fg = colors.warning })
    vim.api.nvim_set_hl(0, "StarterQuote", { fg = colors.secondary })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniStarterOpened",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        for i = 32, 126 do
          pcall(vim.keymap.del, "n", string.char(i), { buffer = buf })
        end

        local ns = vim.api.nvim_create_namespace("starter_quote")
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for l, line in ipairs(lines) do
          for pos in line:gmatch("()[\"]") do
            pcall(vim.api.nvim_buf_add_highlight, buf, ns, "StarterQuote", l - 1, pos - 1, pos)
          end
        end
      end,
    })
  end,
}
