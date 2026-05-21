-- lua/plugins/formatting.lua
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "black" },
        java       = { "google-java-format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        tsx        = { "prettier" },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    })
  end,
}
