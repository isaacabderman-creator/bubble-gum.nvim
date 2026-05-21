return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      check_ts = true, -- integrate with Treesitter for better pairs
      enable_check_bracket_line = true,
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
      fast_wrap = {}, -- optional: <M-e> to fast wrap
    })
  end,
}
