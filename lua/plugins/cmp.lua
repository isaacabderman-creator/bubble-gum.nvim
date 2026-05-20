return {
  {
    "saghen/blink.cmp",
    version = "v1.*",
    lazy = false,
    build = "cargo build --release",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
        use_nvim_cmp_as_default = false,
      },

      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      snippets = { preset = "luasnip" },

      signature = { enabled = true },
    },

    config = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      require("blink.cmp").setup(opts)
    end,
  },
}
