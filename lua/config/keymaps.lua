vim.keymap.set("n", "-", "<CMD>Oil<CR>", { silent = true, desc = "Open parent directory" })
-- LSP Keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Go to Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Show documentation" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, desc = "Code Action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

vim.keymap.set("i", "jk", "<Esc>", { silent = true, desc = "Exit insert mode with jk" })
vim.keymap.set("i", "jj", "<Esc>", { silent = true, desc = "Exit insert mode with jj" })

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  pcall(function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end)
end, { silent = true, desc = "Format file/range" })
