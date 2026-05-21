return {
  {
    name = "colorscheme",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd(os.getenv("NVIM_COLORSCHEME") == "matugen" and "colorscheme matugen" or "colorscheme tmux")
    end,
  },
}
