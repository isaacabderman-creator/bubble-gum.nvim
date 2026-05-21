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

local wanted_lang = {}
for _, lang in ipairs(languages) do
  wanted_lang[lang] = true
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter").setup()

      local installing = {} ---@type table<string, boolean>

      local group = vim.api.nvim_create_augroup("NvimTreesitterConfig", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "*",
        callback = function(ev)
          local bufnr = ev.buf
          local ft = vim.bo[bufnr].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          if not wanted_lang[lang] then
            return
          end

          local ok = pcall(vim.treesitter.start, bufnr, lang)
          if not ok then
            if not installing[lang] then
              installing[lang] = true
              vim.schedule(function()
                pcall(require("nvim-treesitter").install, { lang }, { summary = true })
                installing[lang] = nil
              end)
            end
            return
          end

          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
