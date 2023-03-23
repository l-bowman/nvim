-- local function is_inside_specific_folder()
--   local target_folder = "/Users/lukebowman/Documents/dev/codereview"
--   local current_working_directory = vim.fn.getcwd()
--   return current_working_directory:find(target_folder, 1, true) ~= nil
-- end
local function is_on_master_branch()
  local git_branch_cmd = "git rev-parse --abbrev-ref HEAD 2>/dev/null"
  local current_branch = vim.fn.system(git_branch_cmd):gsub("%s+", "")

  return current_branch == "master"
end

local function custom_warning_indicator()
  if is_on_master_branch() then
    return "CAUTION! " .. string.rep("⚠️", 10) .. " WORKING ON MASTER BRANCH!" -- This will create a string with 10 warning symbols
  else
    return ""
  end
end
return {

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = true,
        components_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
        theme = "tokyonight",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { "encoding", "filetype", custom_warning_indicator },
        lualine_y = { "progress" },
        lualine_z = { "location" },
        lualine_x = {
          { "filename", file_status = true, path = 1 },
        },
        -- lualine_x = {"encoding", "fileformat", "filetype"},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { "fugitive", "nvim-tree" },
    },
  },
}
