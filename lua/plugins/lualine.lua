return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 
    'nvim-tree/nvim-web-devicons', 
  },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = function()
          local ok, p = pcall(require, "matugen_colors")
          if not ok then
            ok, p = pcall(require, "tmux_colors")
          end
          if not ok then
            return "auto"
          end
          local c = p.colors
          return {
            normal = { a = { fg = c.on_primary, bg = c.primary, gui = "bold" }, b = { fg = c.on_surface, bg = c.surface_variant }, c = { fg = c.on_surface, bg = c.surface } },
            insert = { a = { fg = c.on_primary, bg = c.tertiary, gui = "bold" } },
            visual = { a = { fg = c.on_primary, bg = c.secondary, gui = "bold" } },
            replace = { a = { fg = c.on_primary, bg = c.error, gui = "bold" } },
            command = { a = { fg = c.on_primary, bg = c.outline, gui = "bold" } },
            inactive = { a = { fg = c.outline, bg = c.background }, b = { fg = c.outline, bg = c.background }, c = { fg = c.outline, bg = c.background } },
          }
        end,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16, -- ~60fps
        }
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
  end,
}
