vim.keymap.set("n", "-", "<CMD>Canola<CR>", { silent = true, desc = "Open parent directory" })
-- LSP Keymaps
local function resolve_quoted_path()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local match_start, match_end, path = string.find(line, "['\"]([^'\"]+)['\"]", 1)
  while match_start and match_end do
    if col >= match_start - 1 and col <= match_end then
      break
    end
    match_start, match_end, path = string.find(line, "['\"]([^'\"]+)['\"]", match_end + 1)
  end

  if not path then
    return false
  end

  local buf_dir = vim.fn.expand("%:p:h")
  local resolved = vim.fn.resolve(vim.fn.fnamemodify(buf_dir .. "/" .. path, ":p"))

  if vim.fn.filereadable(resolved) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(resolved))
    return true
  end

  for _, ext in ipairs({ ".js", ".ts", ".jsx", ".tsx", "/index.js", "/index.ts", "/index.svelte", ".svelte" }) do
    if vim.fn.filereadable(resolved .. ext) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(resolved .. ext))
      return true
    end
  end

  return false
end

vim.keymap.set("n", "gd", function()
  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
  if #clients > 0 then
    local params = vim.lsp.util.make_position_params()
    local pending = #clients
    local handled = false
    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
      pending = pending - 1
      if handled then
        return
      end

      if not err and result and #result > 0 then
        handled = true
        local loc = result[1]
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetSelectionRange
        if uri then
          local fname = vim.uri_to_fname(uri)
          vim.cmd("edit " .. vim.fn.fnameescape(fname))
          if range then
            vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
          end
        end
        return
      end

      if pending == 0 then
        handled = true
        if not resolve_quoted_path() then
          vim.notify("No definition found", vim.log.levels.INFO)
        end
      end
    end)
  else
    if not resolve_quoted_path() then
      vim.notify("No LSP client or path found", vim.log.levels.INFO)
    end
  end
end, { silent = true, desc = "Go to Definition (path-aware)" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Show documentation" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, desc = "Code Action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

vim.keymap.set("v", "<C-c>", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("i", "jk", "<Esc>", { silent = true, desc = "Exit insert mode with jk" })
vim.keymap.set("i", "jj", "<Esc>", { silent = true, desc = "Exit insert mode with jj" })

local function toggle_comment()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("[vV]") then
    local start = vim.fn.line("v")
    local end_ = vim.fn.line(".")
    if start > end_ then
      start, end_ = end_, start
    end
    require("mini.comment").toggle_lines(start, end_)
  else
    local line = vim.fn.line(".")
    require("mini.comment").toggle_lines(line, line)
  end
end
vim.keymap.set({ "n", "v" }, "<C-/>", toggle_comment, { desc = "Toggle comment" })
vim.keymap.set({ "n", "v" }, "<C-_>", toggle_comment, { desc = "Toggle comment (alt)" })

vim.keymap.set("n", "<leader>wb", function()
  if vim.fn.executable("elinks") == 0 then
    vim.notify("elinks not found on PATH", vim.log.levels.WARN)
    return
  end
  vim.cmd("tab term elinks " .. vim.fn.input("URL: ", "https://"))
end, { desc = "Open web browser (elinks)" })

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  pcall(function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end)
end, { silent = true, desc = "Format file/range" })
