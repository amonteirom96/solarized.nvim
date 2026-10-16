---@class solarized
local M = {}

--- Bump to invalidate every user's compiled cache after changing highlights.
M.version = "1.0.0"

local cache_dir = vim.fn.stdpath("cache") .. "/solarized"
local configured = false
local key ---@type string?

---@param opts? solarized.Config
function M.setup(opts)
  require("solarized.config").set(opts)
  configured = true
  key = nil
end

---@return solarized.Config
local function options()
  return require("solarized.config").options
end

---@return string
local function cache_key()
  if not key then
    key = configured and require("solarized.config").hash() or ("default-" .. M.version)
  end
  return key
end

---@param name string
---@return solarized.Variant
local function resolve_variant(name)
  if name == "solarized-light" then
    return "light"
  elseif name == "solarized-dark" then
    return "dark"
  end
  local v = options().variant
  if v == "light" or v == "dark" then
    return v
  end
  return vim.o.background == "light" and "light" or "dark"
end

--- Full palette (base + derived) for a variant, after `on_colors`.
---@param variant? solarized.Variant defaults to the current 'background'
---@return solarized.Colors
function M.colors(variant)
  return require("solarized.palette").get(variant or resolve_variant("solarized"), options())
end

--- Final highlight table for a variant, after `on_highlights`.
---@param variant? solarized.Variant
---@return table<string, solarized.Style>
function M.highlights(variant)
  local o = options()
  return require("solarized.groups").get(M.colors(variant), o)
end

---@param name string
---@param variant solarized.Variant
---@return string
local function build(name, variant)
  local o = options()
  local c = require("solarized.palette").get(variant, o)
  local hl = require("solarized.groups").get(c, o)
  local term = o.terminal_colors and require("solarized.terminal").ansi(c) or nil
  return require("solarized.compiler").source(name, variant, hl, term)
end

---@param prefix string
---@param keep string
local function prune(prefix, keep)
  for file in vim.fs.dir(cache_dir) do
    if vim.startswith(file, prefix) and file ~= keep then
      os.remove(cache_dir .. "/" .. file)
    end
  end
end

--- Entry point used by `colors/*.lua`.
---@param name? "solarized"|"solarized-light"|"solarized-dark"
function M.load(name)
  name = name or "solarized"
  local variant = resolve_variant(name)

  if not options().cache then
    return assert(load(build(name, variant), "=solarized"))()
  end

  local prefix = name .. "_" .. variant .. "_"
  local file = prefix .. cache_key()
  local path = cache_dir .. "/" .. file
  local fn = loadfile(path)
  if not fn then
    fn = require("solarized.compiler").write(build(name, variant), path)
    prune(prefix, file)
  end
  fn()
end

--- Rebuild the cache for the active colorscheme (e.g. after editing an
--- `on_highlights` closure whose upvalues changed).
function M.compile()
  M.clear_cache()
  local name = vim.g.colors_name
  if name and vim.startswith(name, "solarized") then
    vim.cmd.colorscheme(name)
  end
end

function M.clear_cache()
  vim.fn.delete(cache_dir, "rf")
  key = nil
end

--- Generate terminal/tool themes (ghostty, kitty, lazygit) from the palette.
---@param dir? string output directory, defaults to `<plugin>/extras`
function M.extras(dir)
  return require("solarized.extras").generate(dir)
end

return M
