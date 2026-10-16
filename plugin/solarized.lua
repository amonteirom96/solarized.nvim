if vim.g.loaded_solarized then
  return
end
vim.g.loaded_solarized = true

local cmd = vim.api.nvim_create_user_command

cmd("SolarizedCompile", function()
  require("solarized").compile()
end, { desc = "solarized: rebuild the compiled highlight cache" })

cmd("SolarizedClearCache", function()
  require("solarized").clear_cache()
end, { desc = "solarized: delete the compiled highlight cache" })

cmd("SolarizedExtras", function(args)
  local out = require("solarized").extras(args.args ~= "" and args.args or nil)
  vim.notify("solarized: extras written to " .. out)
end, { nargs = "?", complete = "dir", desc = "solarized: generate ghostty/kitty/lazygit themes" })
