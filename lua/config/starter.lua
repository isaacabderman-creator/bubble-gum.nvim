-- Dependency-free start screen.
--
-- The poem is the hero: it fades in line by line, tinted along a cool gradient,
-- until the closing line ("...to forge one sword") lands in forge-gold and a
-- blade unsheathes beneath it, glowing from cold steel at the hilt to white-hot
-- at the tip.

local M = {}

local palette = require("tmux_colors").colors

local QUOTE = {
  "In my youth I knew the hardships of the world,",
  "Yet I still aspired to soar above the clouds.",
  "A journey of cold winds and uncertainty,",
  "A lone traveler experiences a life of ups and downs.",
  "A heart of steel forged from countless setbacks,",
  "A lifetime of effort to forge one sword.",
}

-- Both rows must stay the same character count: the wordmark's horizontal
-- gradient is indexed per character, so a mismatch would skew row two.
local WORDMARK = {
  "█▀█ █▀▀ █▀█ █▀▀ █▀▀ █ █ █▀▀ █▀█ ▄▀█ █▄ █ █▀▀ █▀▀",
  "█▀▀ ██▄ █▀▄ ▄▄█ ██▄ ▀▄▀ ██▄ █▀▄ █▀█ █ ▀█ █▄▄ ██▄",
}

local ATTRIBUTION = "— Fang Yuan · Reverend Insanity"

-- Animation shape, in milliseconds.
local STAGGER = 55 -- delay added per successive row
local FADE = 260 -- how long a single row takes to reach full color
local TICK = 16 -- redraw interval (~60fps)

local WHITE_HOT = "#fff6e0"

local ns = vim.api.nvim_create_namespace("tmux_starter")
local key_ns = vim.api.nvim_create_namespace("tmux_starter_keys")
local augroup = vim.api.nvim_create_augroup("TmuxStarter", { clear = true })

local state = {
  buf = nil,
  win = nil,
  timer = nil,
  footer = nil,
}

--- Split a hex color into its 8-bit channels.
local function hex_to_rgb(hex)
  local hex_digits = hex:gsub("#", "")
  return tonumber(hex_digits:sub(1, 2), 16), tonumber(hex_digits:sub(3, 4), 16), tonumber(hex_digits:sub(5, 6), 16)
end

--- Linearly mix two hex colors; t=0 yields `from`, t=1 yields `to`.
local function blend(from, to, t)
  local r1, g1, b1 = hex_to_rgb(from)
  local r2, g2, b2 = hex_to_rgb(to)
  return string.format(
    "#%02x%02x%02x",
    math.floor(r1 + (r2 - r1) * t + 0.5),
    math.floor(g1 + (g2 - g1) * t + 0.5),
    math.floor(b1 + (b2 - b1) * t + 0.5)
  )
end

--- Spread a list of color stops into exactly `n` evenly interpolated colors.
local function ramp(stops, n)
  if n <= 1 then
    return { stops[1] }
  end

  local out = {}
  for i = 1, n do
    local pos = (i - 1) / (n - 1) * (#stops - 1)
    local idx = math.min(math.floor(pos) + 1, #stops - 1)
    out[i] = blend(stops[idx], stops[idx + 1], pos - (idx - 1))
  end
  return out
end

--- Byte spans of each UTF-8 character, so multibyte glyphs can be highlighted
--- individually (extmark columns are byte offsets, not character offsets).
local function utf8_chars(s)
  local out = {}
  local i = 1
  while i <= #s do
    local byte = s:byte(i)
    local len = 1
    if byte >= 240 then
      len = 4
    elseif byte >= 224 then
      len = 3
    elseif byte >= 192 then
      len = 2
    end
    out[#out + 1] = { from = i - 1, to = i + len - 1 }
    i = i + len
  end
  return out
end

local function blade(width)
  return "◈══╡" .. string.rep("━", math.max(width - 5, 1)) .. "▶"
end

local function lazy_stats()
  local ok, lazy = pcall(require, "lazy")
  if not ok then
    return nil
  end

  local stats = lazy.stats()
  local ms = math.floor((stats.startuptime or 0) + 0.5)
  if ms <= 0 then
    return string.format("%d plugins", stats.count)
  end
  return string.format("%d plugins · %dms", stats.count, ms)
end

--- Build the screen as a list of rows. Each row carries the text plus the
--- per-character colors to paint it with; centering happens later, once the
--- window width is known.
local function compose()
  local rows = {}

  local function add(text, colors, opts)
    rows[#rows + 1] = vim.tbl_extend("force", { text = text, colors = colors }, opts or {})
  end

  local mark_colors = ramp({ palette.primary, palette.tertiary }, vim.fn.strchars(WORDMARK[1]))
  for _, line in ipairs(WORDMARK) do
    add(line, mark_colors)
  end
  add("")

  -- Cool gradient over the opening lines, then the payoff line in forge-gold.
  local body = #QUOTE - 1
  local quote_colors = ramp({ palette.tertiary, palette.secondary, palette.primary }, body)
  for i = 1, body do
    add(QUOTE[i], { quote_colors[i] })
  end
  add(QUOTE[#QUOTE], { palette.warning }, { bold = true })
  add("")

  local edge = blade(46)
  add(edge, ramp({ palette.outline_variant, palette.error, palette.warning, WHITE_HOT }, vim.fn.strchars(edge)))
  add("")

  add(ATTRIBUTION, { palette.outline }, { italic = true })

  local stats = lazy_stats()
  if stats then
    add(stats, { palette.outline_variant }, { footer = true })
  end

  return rows
end

--- Render `rows` into the buffer, centered in the window, and return the
--- highlight jobs the animation will drive.
local function paint(buf, win, rows)
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  local content_height = #rows
  local top_pad = math.max(math.floor((height - content_height) / 2) - 1, 0)

  local lines = {}
  for _ = 1, top_pad do
    lines[#lines + 1] = ""
  end

  local placements = {}
  for i, row in ipairs(rows) do
    local pad = row.text == "" and 0 or math.max(math.floor((width - vim.fn.strdisplaywidth(row.text)) / 2), 0)
    local text = string.rep(" ", pad) .. row.text
    lines[#lines + 1] = text
    placements[#placements + 1] = { row = top_pad + i - 1, text = text, pad = pad, spec = row, order = i }
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  -- One highlight group per painted span. Animating means recoloring these
  -- groups, so the extmarks themselves are placed exactly once.
  state.footer = nil
  local jobs = {}

  local function mark(place, from, to, index, color)
    local group = string.format("TmuxStarter%d_%d", place.order, index)
    local id = vim.api.nvim_buf_set_extmark(buf, ns, place.row, from, {
      end_col = to,
      hl_group = group,
    })
    jobs[#jobs + 1] = {
      group = group,
      color = color,
      bold = place.spec.bold,
      italic = place.spec.italic,
      delay = (place.order - 1) * STAGGER,
    }
    return group, id
  end

  for _, place in ipairs(placements) do
    if place.spec.text ~= "" then
      local colors = place.spec.colors

      if #colors == 1 then
        -- A uniformly colored row needs a single extmark spanning the line.
        local group, id = mark(place, place.pad, #place.text, 1, colors[1])
        if place.spec.footer then
          state.footer = { row = place.row, group = group, extmark = id }
        end
      else
        for idx, span in ipairs(utf8_chars(place.spec.text)) do
          mark(place, place.pad + span.from, place.pad + span.to, idx, colors[math.min(idx, #colors)])
        end
      end
    end
  end

  return jobs
end

--- Swap in the real startup timing once lazy.nvim knows it. Called early
--- enough that the footer is still fully faded out, so the text never visibly
--- changes under the reader.
local function refresh_footer()
  local footer = state.footer
  if not footer then
    return
  end

  local buf, win = state.buf, state.win
  if not (buf and vim.api.nvim_buf_is_valid(buf) and win and vim.api.nvim_win_is_valid(win)) then
    return
  end

  local text = lazy_stats()
  if not text then
    return
  end

  local pad = math.max(math.floor((vim.api.nvim_win_get_width(win) - vim.fn.strdisplaywidth(text)) / 2), 0)
  local line = string.rep(" ", pad) .. text

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, footer.row, footer.row + 1, false, { line })
  vim.bo[buf].modifiable = false

  vim.api.nvim_buf_set_extmark(buf, ns, footer.row, pad, {
    id = footer.extmark,
    end_col = #line,
    hl_group = footer.group,
  })
end

local function stop_key_watch()
  pcall(vim.on_key, nil, key_ns)
end

local function stop_timer()
  if state.timer then
    state.timer:stop()
    if not state.timer:is_closing() then
      state.timer:close()
    end
    state.timer = nil
  end
end

--- Fade every span up from the background color to its target.
local function animate(jobs)
  stop_timer()

  local bg = palette.background
  local function apply(job, t)
    -- Smoothstep, so rows ease in rather than ramping linearly.
    local eased = t * t * (3 - 2 * t)
    vim.api.nvim_set_hl(0, job.group, {
      fg = blend(bg, job.color, eased),
      bold = job.bold,
      italic = job.italic,
    })
  end

  for _, job in ipairs(jobs) do
    apply(job, 0)
  end

  local elapsed = 0
  local longest = 0
  for _, job in ipairs(jobs) do
    longest = math.max(longest, job.delay)
  end
  local duration = longest + FADE

  local timer = vim.uv.new_timer()
  state.timer = timer
  timer:start(
    TICK,
    TICK,
    vim.schedule_wrap(function()
      -- The splash can be dismissed mid-animation.
      if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
        stop_timer()
        return
      end

      elapsed = elapsed + TICK
      for _, job in ipairs(jobs) do
        if not job.done then
          local t = math.min(math.max((elapsed - job.delay) / FADE, 0), 1)
          apply(job, t)
          job.done = t >= 1
        end
      end

      if elapsed >= duration then
        stop_timer()
        stop_key_watch()
      end
    end)
  )
end

--- Skip straight to the finished frame.
local function settle(jobs)
  stop_timer()
  stop_key_watch()
  for _, job in ipairs(jobs) do
    vim.api.nvim_set_hl(0, job.group, { fg = job.color, bold = job.bold, italic = job.italic })
    job.done = true
  end
end

function M.open()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_get_current_win()

  state.buf = buf
  state.win = win

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "starter"

  vim.api.nvim_win_set_buf(win, buf)

  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.cursorline = false
  wo.signcolumn = "no"
  wo.colorcolumn = ""
  wo.foldcolumn = "0"
  wo.list = false
  wo.wrap = false
  wo.spell = false
  wo.fillchars = "eob: "

  local rows = compose()
  local jobs = paint(buf, win, rows)
  animate(jobs)

  -- Any keypress lands the animation immediately rather than making the user
  -- sit through it. This watches keys rather than mapping them, so the leader
  -- key and every other mapping stay untouched on the splash.
  vim.on_key(function()
    stop_key_watch()
    vim.schedule(function()
      settle(jobs)
    end)
  end, key_ns)

  vim.keymap.set("n", "q", "<Cmd>qa<CR>", { buffer = buf, silent = true, nowait = true, desc = "Quit" })
  vim.keymap.set("n", "e", "<Cmd>enew<CR>", { buffer = buf, silent = true, nowait = true, desc = "New file" })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    buffer = buf,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) then
        settle(paint(buf, win, compose()))
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    buffer = buf,
    callback = function()
      stop_timer()
      stop_key_watch()
      state.buf = nil
    end,
  })

  -- lazy.nvim only records startup time on UIEnter, which lands after this
  -- runs. Retry twice while the footer is still invisible behind its fade.
  vim.defer_fn(refresh_footer, 120)
  vim.defer_fn(refresh_footer, 500)
end

--- Only greet an genuinely empty session: no file arguments, no piped stdin,
--- and nothing already loaded into the current buffer.
local function should_open()
  if vim.fn.argc(-1) > 0 or vim.g.starter_disabled or vim.g.read_from_stdin then
    return false
  end

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].filetype ~= "" then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #lines <= 1 and (lines[1] or "") == ""
end

function M.setup()
  vim.api.nvim_create_autocmd("StdinReadPre", {
    group = augroup,
    callback = function()
      vim.g.read_from_stdin = true
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    nested = true,
    callback = function()
      if should_open() then
        M.open()
      end
    end,
  })
end

return M
