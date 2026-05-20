return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { 
          "lua", "vim", "vimdoc", "query", "bash", 
          "markdown", "markdown_inline", "regex", "hyprlang",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "java",
          "html",
          "svelte",
          "css"
        },
        
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        
        -- Better indentation based on code structure
        indent = { enable = true },
        
      })
    end,
  },
}
