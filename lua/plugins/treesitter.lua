local languages = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "bash",
  "markdown",
  "markdown_inline",
  "regex",
  "hyprlang",
  "python",
  "javascript",
  "typescript",
  "tsx",
  "java",
  "html",
  "svelte",
  "css",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup()

      local group = vim.api.nvim_create_augroup("NvimTreesitterConfig", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = languages,
        callback = function()
          vim.treesitter.start()
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
