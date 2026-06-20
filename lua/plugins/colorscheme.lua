return {
  {
    name = "tmux-colorscheme",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tmux")
    end,
  },
}
