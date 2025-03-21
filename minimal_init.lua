-- minimal_init.lua
-- Basic settings and options
require("options")
-- Define a whitelist of configuration files to load
local config_whitelist = {
  "harpoon",
  "telescope", -- Corresponds to lua/plugins/telescope.lua
  "whichkey",
  -- Add more configuration files you want to load here
}
-- Function to check if a configuration file is in the whitelist
local function is_config_whitelisted(config_name)
  for _, name in ipairs(config_whitelist) do
    if config_name == name then
      return true
    end
  end
  return false
end
-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- Collect all plugin specifications
local plugins = {}
-- Load configuration files from your existing plugin directory
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local plugin_files = vim.fn.globpath(plugin_dir, "*.lua", false, true)
for _, file in ipairs(plugin_files) do
  local config_name = file:match("([^/]+)%.lua$")
  if is_config_whitelisted(config_name) then
    print("Loading plugin config:", config_name) -- Debugging line
    local plugin_config = require("plugins." .. config_name)
    if type(plugin_config) == "table" then
      for _, plugin in ipairs(plugin_config) do
        if type(plugin) == "table" then
          table.insert(plugins, plugin)
        else
          print("Warning: Non-table plugin spec in", config_name, ":", type(plugin))
        end
      end
    else
      print("Error: Config file does not return a table:", config_name)
    end
  else
    print("Skipping plugin config:", config_name) -- Debugging line
  end
end
-- Setup plugins with lazy.nvim
require("lazy").setup(plugins, { ui = { border = "rounded" } })
-- Key mappings
require("keymappings")
-- Utilities
require("utils")
require("playwright")
require("vue-shortcuts")
require("import")
