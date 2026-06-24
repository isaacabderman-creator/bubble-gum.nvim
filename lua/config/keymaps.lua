vim.keymap.set("n", "-", "<CMD>Oil<CR>", { silent = true, desc = "Open parent directory" })
-- LSP Keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Go to Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Show documentation" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, desc = "Code Action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

vim.keymap.set("v", "<C-c>", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("i", "jk", "<Esc>", { silent = true, desc = "Exit insert mode with jk" })
vim.keymap.set("i", "jj", "<Esc>", { silent = true, desc = "Exit insert mode with jj" })

vim.keymap.set({ "n", "v" }, "<C-/>", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("[vV]") then
    local start = vim.fn.line("v")
    local end_ = vim.fn.line(".")
    if start > end_ then start, end_ = end_, start end
    require("mini.comment").toggle_lines(start, end_)
  else
    local line = vim.fn.line(".")
    require("mini.comment").toggle_lines(line, line)
  end
end, { desc = "Toggle comment" })
vim.keymap.set({ "n", "v" }, "<C-_>", function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("[vV]") then
    local start = vim.fn.line("v")
    local end_ = vim.fn.line(".")
    if start > end_ then start, end_ = end_, start end
    require("mini.comment").toggle_lines(start, end_)
  else
    local line = vim.fn.line(".")
    require("mini.comment").toggle_lines(line, line)
  end
end, { desc = "Toggle comment (alt)" })

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  pcall(function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end)
end, { silent = true, desc = "Format file/range" })
