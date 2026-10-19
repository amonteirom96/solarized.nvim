local util = require("solarized.util")

local M = {}

--- Solarized backgrounds and hue families, with accents adjusted for AA
--- contrast on Normal and surface2. Red is reserved for errors and deletions.
---@type table<"light"|"dark", solarized.BasePalette>
M.base = {
  light = {
    bg = "#fdf6e3",
    fg = "#52676f",
    red = "#c62d2a",
    orange = "#b64314",
    yellow = "#846400",
    green = "#616f00",
    cyan = "#1e746e",
    azure = "#1e6da5",
    blue = "#1e6da5",
  },
  dark = {
    bg = "#0c2b31",
    fg = "#93a1a1",
    red = "#e87876",
    orange = "#db825d",
    yellow = "#bc9417",
    green = "#8fa215",
    cyan = "#3ba9a0",
    azure = "#4ca0da",
    blue = "#4ca0da",
  },
}

---@class solarized.BasePalette
---@field bg string
---@field fg string
---@field red string
---@field orange string
---@field yellow string
---@field green string
---@field cyan string
---@field azure string
---@field blue string

---@class solarized.Colors: solarized.BasePalette
---@field variant "light"|"dark"
---@field none "NONE"
---@field bg_float string
---@field bg_dim string      background for inactive windows (dim_inactive)
---@field surface1 string    cursorline, subtle rows
---@field surface2 string    selection, active tab, statusline
---@field surface3 string    stronger selection / match paren
---@field select string      current item in lists: popup menu, pickers, file explorers
---@field border string
---@field muted string       UI chrome only (line numbers, whitespace) — never code
---@field comment string     comments: fg faded toward bg, still WCAG AA
---@field accent string      single UI focal color (matches, prompts)
---@field search string      background for search matches
---@field code { string: string, func: string, type: string, constant: string }  the only hues used in code
---@field git { add: string, change: string, delete: string }
---@field diag { error: string, warn: string, info: string, hint: string, ok: string }

--- Build the full, derived color table for a variant.
---@param variant "light"|"dark"
---@param opts solarized.Config
---@return solarized.Colors
function M.get(variant, opts)
  local b = vim.deepcopy(M.base[variant])
  local c = b --[[@as solarized.Colors]]
  local is_light = variant == "light"
  local blend = util.blend

  c.variant = variant
  c.none = "NONE"

  -- Neutral surfaces follow the warm paper / softened blue-green bases.
  local tint = c.fg
  c.surface1 = blend(tint, c.bg, is_light and 0.05 or 0.06)
  c.surface2 = blend(tint, c.bg, is_light and 0.08 or 0.085)
  c.surface3 = blend(tint, c.bg, is_light and 0.14 or 0.13)
  -- Current item in every list (Pmenu, pickers, explorers). surface2 is too
  -- faint to spot at a glance, so both variants use surface3 (about the same
  -- perceived lightness step from bg in light and dark).
  c.select = c.surface3
  c.border = blend(tint, c.bg, is_light and 0.24 or 0.22)
  c.muted = blend(c.fg, c.bg, is_light and 0.76 or 0.65)
  -- Comments step back from the code without dropping below AA (4.5:1): fg
  -- faded toward bg. Italic does the rest.
  c.comment = blend(blend(tint, c.fg, 0.35), c.bg, is_light and 0.95 or 0.90)
  c.bg_dim = is_light and blend(c.fg, c.bg, 0.03) or util.darken(c.bg, 0.12)
  c.bg_float = c.bg
  c.accent = c.blue
  -- Tinted accent, same hue family as the UI so it stays clean. Stronger than
  -- surface3 so it reads apart from Visual.
  c.search = blend(c.accent, c.bg, is_light and 0.25 or 0.32)

  local mono = opts.mono
  c.code = {
    string = mono and c.fg or c.green,
    func = mono and c.fg or c.blue,
    type = mono and c.fg or c.yellow,
    constant = mono and c.fg or c.orange,
  }
  c.git = { add = c.green, change = c.blue, delete = c.red }
  c.diag = { error = c.red, warn = c.yellow, info = c.blue, hint = c.cyan, ok = c.green }

  if opts.on_colors then
    opts.on_colors(c, variant)
  end
  return c
end

return M
