return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- Label the leader prefixes; individual mappings still describe
      -- themselves through their own `desc`.
      spec = {
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>j", group = "Java" },
        { "<leader>o", group = "Tasks" },
        { "<leader>s", group = "Search" },
        { "<leader>t", group = "Test" },
        { "<leader>x", group = "Diagnostics" },
      },
    },
  },
}
