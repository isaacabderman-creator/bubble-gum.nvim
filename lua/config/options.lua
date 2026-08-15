local opt = vim.opt

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.clipboard = "unnamedplus"
opt.undofile = true

-- Code folding, structure-aware via treesitter. Nothing is folded when a file
-- opens (foldlevel 99); folds are opt-in with za/zc/zo, or zR/zM for all.
-- An empty foldtext keeps the folded line syntax-highlighted instead of
-- replacing it with vim's plain "+--" summary.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldnestmax = 6
opt.fillchars:append({ fold = " " })

vim.env.PATH = vim.env.PATH .. ":/usr/local/bin" -- NOTE: update path to match `which mvn`

vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})
