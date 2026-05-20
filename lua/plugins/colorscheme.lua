return {
  {
    name = "tmux-colorscheme",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      if os.getenv("NVIM_COLORSCHEME") ~= "matugen" then
        vim.cmd("colorscheme tmux")
      end
    end,
  },
  {
    name = "matugen-colorscheme",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      if os.getenv("NVIM_COLORSCHEME") == "matugen" then
        vim.cmd("colorscheme matugen")
      end
    end,
  },
}
