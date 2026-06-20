local markdown_extensions = {
  md = true,
  markdown = true,
  mkd = true,
  mdown = true,
}

local function is_markdown(path)
  if path == "" then
    return false
  end

  if vim.fn.isdirectory(path) == 1 then
    return false
  end

  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return markdown_extensions[ext] == true
end

local function should_launch_neovide()
  if vim.g.neovide then
    return false
  end

  local args = vim.fn.argv()
  if #args == 0 then
    return false
  end

  for _, arg in ipairs(args) do
    if not is_markdown(arg) then
      return false
    end
  end

  return true
end

local group = vim.api.nvim_create_augroup("NeovideMarkdownLauncher", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    if not should_launch_neovide() then
      return
    end

    if vim.fn.executable("neovide") ~= 1 then
      vim.api.nvim_echo({
        { "Neovide is not installed; staying in terminal Neovim.", "WarningMsg" },
      }, true, {})
      return
    end

    local cmd = vim.list_extend({ "neovide" }, vim.fn.argv())
    local job_id = vim.fn.jobstart(cmd, { detach = true })
    if job_id <= 0 then
      vim.api.nvim_echo({
        { "Failed to launch Neovide for the markdown session.", "ErrorMsg" },
      }, true, {})
      return
    end

    vim.cmd("qa!")
  end,
})
