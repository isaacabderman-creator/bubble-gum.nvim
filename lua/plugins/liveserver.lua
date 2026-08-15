local port = 8080

local function server_dir()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(bufname, ":p:h")
end

local pid = nil

vim.api.nvim_create_user_command("LiveServerStart", function()
  if pid then
    vim.notify("already running on port " .. port, vim.log.levels.INFO)
    return
  end
  local dir = server_dir()
  pid = vim.fn.jobstart({ "python3", "-m", "http.server", tostring(port), "-d", dir }, {
    detach = true,
    on_exit = function(_, _)
      pid = nil
    end,
  })
  vim.notify("server started on http://127.0.0.1:" .. port .. "  (" .. dir .. ")", vim.log.levels.INFO)
  vim.ui.open("http://127.0.0.1:" .. port)
end, {})

vim.api.nvim_create_user_command("LiveServerStop", function()
  if not pid then
    vim.notify("no server running", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstop(pid)
  pid = nil
  vim.notify("server stopped", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("LiveServerToggle", function()
  if pid then
    vim.cmd("LiveServerStop")
  else
    vim.cmd("LiveServerStart")
  end
end, {})

return {}
