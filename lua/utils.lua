-- Table to store multiple named quickfix lists
local quickfix_lists = {}
-- Function to add the current line to a named quickfix list
local function add_current_line_to_named_quickfix(list_name)
  -- Get the current buffer's file name
  local filename = vim.fn.expand("%:p")
  -- Get the current line number
  local line_number = vim.fn.line(".")
  -- Get the text of the current line
  local text = vim.fn.getline(line_number)
  -- Create a new quickfix entry
  local entry = {
    filename = filename,
    lnum = line_number,
    col = 1, -- Column number (1-based index)
    text = text,
  }
  -- Initialize the quickfix list if it doesn't exist
  if not quickfix_lists[list_name] then
    quickfix_lists[list_name] = {}
  end
  -- Add the new entry to the named quickfix list
  table.insert(quickfix_lists[list_name], entry)
end

_G.AddCurrentLineToNamedQuickfix = add_current_line_to_named_quickfix

-- Function to open a named quickfix list
local function open_named_quickfix(list_name)
  if quickfix_lists[list_name] then
    -- Set the quickfix list to the named list
    vim.fn.setqflist(quickfix_lists[list_name])
    -- Open the quickfix window to show the list
    vim.cmd("copen")
  else
    print("Quickfix list '" .. list_name .. "' does not exist.")
  end
end

_G.OpenNamedQuickfix = open_named_quickfix

local function list_all_quickfix_lists()
  if not quickfix_lists or next(quickfix_lists) == nil then
    print("No quickfix lists available.")
  else
    print("Available Quickfix Lists:")
    for list_name, _ in pairs(quickfix_lists) do
      print("- " .. list_name)
    end
  end
end

_G.ListAllQuickfixLists = list_all_quickfix_lists

-- Table to store multiple named quickfix lists
quickfix_lists = quickfix_lists or {}
-- Default file path for storing quickfix lists
local quickfix_file_path = vim.fn.stdpath("data") .. "/quickfix_lists.lua"
-- Function to serialize a table to a string
local function serialize_table(tbl)
  local result = "{\n"
  for key, value in pairs(tbl) do
    result = result .. string.format("  [%q] = {\n", key)
    for _, entry in ipairs(value) do
      result = result
        .. string.format(
          "    { filename = %q, lnum = %d, col = %d, text = %q },\n",
          entry.filename,
          entry.lnum,
          entry.col,
          entry.text
        )
    end
    result = result .. "  },\n"
  end
  result = result .. "}\n"
  return result
end

-- Function to save quickfix lists to the default file
function _G.save_quickfix_lists()
  local file = io.open(quickfix_file_path, "w")
  if file then
    file:write("return " .. serialize_table(quickfix_lists))
    file:close()
    print("Quickfix lists saved to " .. quickfix_file_path)
  else
    print("Failed to open file for writing: " .. quickfix_file_path)
  end
end
_G.SaveQuickfixLists = save_quickfix_lists

-- Function to load quickfix lists from the default file
function _G.load_quickfix_lists()
  local file = io.open(quickfix_file_path, "r")
  if file then
    file:close()
    quickfix_lists = dofile(quickfix_file_path) or {}
    print("Quickfix lists loaded from " .. quickfix_file_path)
  else
    print("Failed to open file for reading: " .. quickfix_file_path)
  end
end
_G.LoadQuickfixLists = load_quickfix_lists

-- Function to clear the saved quickfix lists
local function clear_saved_quickfix_lists()
  if os.remove(quickfix_file_path) then
    quickfix_lists = {}
    print("Quickfix lists cleared and file deleted.")
  else
    print("No saved quickfix lists to clear.")
  end
end

_G.ClearSavedQuickfixLists = clear_saved_quickfix_lists

-- local function remove_current_qf_entry()
--   -- Get the current quickfix list
--   local quickfix_list = vim.fn.getqflist()
--   -- Get the current quickfix entry index
--   local current_index = vim.fn.getqflist({ idx = 0 }).idx
--   -- Remove the current entry from the quickfix list
--   table.remove(quickfix_list, current_index)
--   -- Set the updated quickfix list
--   vim.fn.setqflist(quickfix_list)
--   -- Move to the next entry if possible
--   if current_index <= #quickfix_list then
--     vim.cmd("cnext")
--   else
--     vim.cmd("cprev")
--   end
-- end
function _G.remove_current_qf_entry(list_name)
  local quickfix_list
  local is_named_list = false
  if list_name and quickfix_lists[list_name] then
    -- Use the named quickfix list
    quickfix_list = quickfix_lists[list_name]
    is_named_list = true
  else
    -- Use the current quickfix list
    quickfix_list = vim.fn.getqflist()
  end
  -- Get the current quickfix entry index
  local current_index = vim.fn.getqflist({ idx = 0 }).idx
  -- Remove the current entry from the quickfix list
  table.remove(quickfix_list, current_index)
  -- Update the quickfix list
  if is_named_list then
    quickfix_lists[list_name] = quickfix_list
  else
    vim.fn.setqflist(quickfix_list)
  end
  -- Close and reopen the quickfix list to refresh the view
  vim.cmd("cclose")
  if not vim.tbl_isempty(quickfix_list) then
    if is_named_list then
      -- Reopen the named quickfix list
      vim.fn.setqflist(quickfix_list)
    end
    vim.cmd("copen")
  end
end

_G.RemoveCurrentQfEntry = remove_current_qf_entry

-- tmux crap
_G.toggle_tmux_pane = function()
  vim.cmd("!tmux display-message 'Test Message'")
end

-- Toggle terminal
-- Store terminal buffer reference
local term_buf = nil

-- Define the global function
_G.toggle_term = function()
  -- Check if a terminal buffer exists and is displayed in a window
  local term_win = nil
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if term_buf and buf == term_buf then
      term_win = win
      break
    end
  end

  -- If terminal window is found, close it
  if term_win then
    vim.api.nvim_win_close(term_win, false) -- Close the window

    -- Ensure term_buf is not nil before deleting
    if term_buf then
      vim.api.nvim_buf_delete(term_buf, { force = true }) -- Delete the buffer
      term_buf = nil -- Reset the terminal buffer reference
    end
    return
  end

  -- Otherwise, create a vertical split to the right
  vim.cmd("vertical rightbelow split")

  -- Set both the current window and the new split to be 50% of Neovim's total width
  local total_width = vim.api.nvim_get_option("columns")
  local half_width = math.floor(total_width / 2)
  vim.api.nvim_win_set_width(0, half_width)
  vim.api.nvim_win_set_width(vim.api.nvim_get_current_win(), half_width)

  -- Start the terminal session with tmux and the desired session name
  vim.cmd("terminal tmux attach -t neovim-terminal || tmux new -s neovim-terminal")
  term_buf = vim.api.nvim_get_current_buf()
end

-- close empty buffers
_G.close_empty_buffers = function()
  local all_bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(all_bufs) do
    if vim.api.nvim_buf_line_count(buf) <= 1 then
      local content = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
      if #content == 0 or content[1] == "" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
end

-- Function to populate the command prompt
local function populate_help_search()
  -- This simulates typing ':vert to help ' into the command line.
  -- The <C-u> clears the command line in case it is not empty.
  -- 'i' flag at the end inserts the keys as if typed by the user.
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes(":vert to help ", true, false, true), "n")
end

-- Create a command in Neovim to use this function
vim.api.nvim_create_user_command("HelpVert", populate_help_search, {})

-- rename file

function Rename_buffer_file(substring, replacement)
  local current_buf = vim.api.nvim_get_current_buf()
  local old_name = vim.api.nvim_buf_get_name(current_buf)

  -- Replace the substring in the filename
  local new_name = old_name:gsub(substring, replacement)

  -- Check if the new filename is different from the old filename
  if new_name ~= old_name then
    -- Rename the file on disk
    os.rename(old_name, new_name)

    -- Update the buffer name in Neovim
    vim.api.nvim_buf_set_name(current_buf, new_name)

    -- Update the buffer statusline
    vim.cmd("redraws")
  end
end

function DeleteUnchangedGitBuffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname ~= "" then
      local git_status = vim.fn.system("git status --porcelain " .. bufname)
      if git_status == "" then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end
end

-- Function to write the current line number and filename to a file on the desktop
local function write_line_info_to_file(opts)
  -- Get the current line number
  local line_number = vim.fn.line(".")
  -- Get the current filename
  local filename = vim.fn.expand("%:p")
  -- Get the home directory path
  local home_dir = os.getenv("HOME")
  -- Specify the output file path on the desktop
  local output_file = home_dir .. "/Desktop/output_file.txt"
  -- Determine the mode based on the argument
  local mode = opts.args == "append" and "a" or "w"
  -- Open the file in the specified mode
  local file = io.open(output_file, mode)
  if file then
    -- Write the line number and filename to the file
    file:write(string.format("Line %d: %s\n", line_number, filename))
    -- Close the file
    file:close()
    -- Notify the user
    print(string.format("Wrote line %d and filename to %s", line_number, output_file))
  else
    -- Notify the user if the file could not be opened
    print("Error: Could not open file " .. output_file)
  end
end
-- Create a command to call the function with an optional argument
vim.api.nvim_create_user_command("WriteLineInfo", write_line_info_to_file, { nargs = "?" })

-- Telescope
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

function _G.checkout_branch_and_reload_session()
  builtin.git_branches({
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Save session
        vim.cmd("SessionSave")

        -- Close all buffers
        vim.cmd("bufdo bd")

        -- Checkout the selected branch
        local command = string.format("git checkout %s", selection.value)
        vim.fn.system(command)

        -- Restore session
        vim.cmd("SessionRestore")
      end)
      return true
    end,
  })
end

-- Function to read the coding standards from a file
local function read_coding_standards(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return "Could not read coding standards."
  end
  local content = file:read("*all")
  file:close()
  return content
end
-- Global function to perform code review
function _G.review_code()
  -- Path to your coding standards file
  local coding_standards_path = "/path/to/your/coding_standards.txt"
  -- Get the changeset using a shell command
  local changeset = vim.fn.system("git diff HEAD~1 HEAD")
  -- Read the coding standards
  local coding_standards = read_coding_standards(coding_standards_path)
  -- Call the ChatGPT action
  require("chatgpt").run_action("code_review", {
    input = changeset,
    coding_standards = coding_standards,
  })
end
