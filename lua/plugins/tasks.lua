return {
  {
    "stevearc/overseer.nvim",
    opts = {
      templates = { "builtin" },
    },
    keys = {
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run Build/Script Task" },
      { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle Task Output Bar" },
    },
  },
}
