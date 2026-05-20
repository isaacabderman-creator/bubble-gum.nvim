if vim.g.colors_name == "tmux" then
  return
end

vim.g.colors_name = "tmux"
vim.o.background = "dark"

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

local ok, palette = pcall(require, "tmux_colors")
if not ok then
  vim.notify("tmux_colors.lua not found.", vim.log.levels.WARN)
  return
end

local c = palette.colors

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Core UI
hi("Normal",       { fg = c.on_background, bg = c.background })
hi("NormalFloat",  { fg = c.on_surface,    bg = c.surface_variant })
hi("FloatBorder",  { fg = c.outline,       bg = c.surface_variant })
hi("CursorLine",   { bg = c.surface_variant })
hi("CursorLineNr", { fg = c.primary,       bold = true })
hi("LineNr",       { fg = c.outline })
hi("SignColumn",   { fg = c.outline,       bg = c.background })
hi("StatusLine",   { fg = c.on_surface,    bg = c.surface })
hi("StatusLineNC", { fg = c.outline,       bg = c.surface })
hi("VertSplit",    { fg = c.outline_variant })
hi("WinSeparator", { fg = c.outline_variant })
hi("Pmenu",        { fg = c.on_surface,    bg = c.surface_variant })
hi("PmenuSel",     { fg = c.on_primary,    bg = c.primary })
hi("PmenuSbar",    { bg = c.surface })
hi("PmenuThumb",   { bg = c.primary })
hi("Search",       { fg = c.on_background, bg = c.warning })
hi("IncSearch",    { fg = c.on_background, bg = c.info })
hi("Visual",       { bg = c.primary_container })

-- Syntax
hi("Comment",      { fg = c.outline,        italic = true })
hi("Constant",     { fg = c.warning })
hi("String",       { fg = c.success })
hi("Identifier",   { fg = c.on_surface })
hi("Function",     { fg = c.secondary,      bold = true })
hi("Statement",    { fg = c.tertiary,       bold = true })
hi("Keyword",      { fg = c.tertiary })
hi("Operator",     { fg = c.on_surface_variant })
hi("Type",         { fg = c.primary })
hi("Special",      { fg = c.info })
hi("Error",        { fg = c.error })
hi("Todo",         { fg = c.on_primary,     bg = c.primary, bold = true })

-- Treesitter
hi("@variable",              { fg = c.on_surface })
hi("@variable.builtin",      { fg = c.secondary, italic = true })
hi("@function",              { link = "Function" })
hi("@function.builtin",      { fg = c.secondary })
hi("@keyword",               { link = "Keyword" })
hi("@keyword.return",        { fg = c.tertiary, italic = true })
hi("@string",                { link = "String" })
hi("@number",                { fg = c.warning })
hi("@boolean",               { fg = c.warning, bold = true })
hi("@type",                  { link = "Type" })
hi("@type.builtin",          { fg = c.primary, italic = true })
hi("@comment",               { link = "Comment" })
hi("@operator",              { link = "Operator" })
hi("@punctuation.bracket",   { fg = c.on_surface_variant })
hi("@punctuation.delimiter", { fg = c.outline })
hi("@tag",                   { fg = c.primary })
hi("@tag.attribute",         { fg = c.secondary })

-- Diagnostics
hi("DiagnosticError",          { fg = c.error })
hi("DiagnosticWarn",           { fg = c.warning })
hi("DiagnosticInfo",           { fg = c.secondary })
hi("DiagnosticHint",           { fg = c.outline })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.warning })

-- Telescope
hi("TelescopeNormal",         { fg = c.on_surface,  bg = c.surface })
hi("TelescopeBorder",         { fg = c.outline,     bg = c.surface })
hi("TelescopePromptNormal",   { fg = c.on_surface,  bg = c.surface_variant })
hi("TelescopePromptBorder",   { fg = c.outline,     bg = c.surface_variant })
hi("TelescopePromptTitle",    { fg = c.on_primary,  bg = c.primary })
hi("TelescopeResultsTitle",   { fg = c.on_surface,  bg = c.surface })
hi("TelescopePreviewTitle",   { fg = c.on_tertiary, bg = c.tertiary })
hi("TelescopeSelection",      { bg = c.primary_container })
hi("TelescopeMatching",       { fg = c.primary,     bold = true })

-- Oil.nvim
hi("OilDir",      { fg = c.primary,   bold = true })
hi("OilFile",     { fg = c.on_surface })
hi("OilLink",     { fg = c.secondary, italic = true })
