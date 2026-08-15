return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Breadcrumbs come from aerial, which only loads on LspAttach. Note that
    -- get_location returns a list of symbol tables, not a string, so it has to
    -- be formatted rather than rendered directly.
    local function breadcrumbs()
      local ok, aerial = pcall(require, "aerial")
      if not ok then
        return ""
      end

      local parts = {}
      for _, symbol in ipairs(aerial.get_location(true) or {}) do
        parts[#parts + 1] = vim.trim((symbol.icon or "") .. " " .. (symbol.name or ""))
      end
      return table.concat(parts, "  ")
    end

    local function has_symbols()
      return package.loaded["aerial"] ~= nil and breadcrumbs() ~= ""
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = { "aerial", "trouble", "toggleterm", "starter", "grug-far", "NeogitStatus" },
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 0, symbols = { modified = "●", readonly = "" } },
          { breadcrumbs, cond = has_symbols, padding = { left = 0, right = 1 } },
        },
      },
      inactive_winbar = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 0, symbols = { modified = "●", readonly = "" } },
        },
      },
      extensions = {},
    })
  end,
}
