local change_list = {}
local max_changes = 20
local current_change_index = 0
local change_file = vim.fn.stdpath("data") .. "/change_list.json"
-- Load changes from disk
local function load_changes()
  local file = io.open(change_file, "r")
  if file then
    local content = file:read("*a")
    change_list = vim.fn.json_decode(content)
    file:close()
  end
end
-- Save changes to disk
local function save_changes()
  local file = io.open(change_file, "w")
  if file then
    file:write(vim.fn.json_encode(change_list))
    file:close()
  end
end
-- Function to capture changes
local function capture_change()
  local bufnr = vim.api.nvim_get_current_buf()
  local change_number = vim.fn.line(".") -- Get the current change number
  local change = {
    buffer = bufnr,
    change_number = change_number,
    timestamp = os.time(),
  }
  -- Add the change to the change list
  table.insert(change_list, change)
  -- Limit the number of changes
  if #change_list > max_changes then
    table.remove(change_list, 1) -- Remove the oldest change
  end
end
-- Set up autocommands to capture changes
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = capture_change,
})
-- Function to navigate changes
local function navigate_changes(direction)
  -- Filter out changes from closed buffers
  local valid_changes = {}
  for _, change in ipairs(change_list) do
    if vim.api.nvim_buf_is_valid(change.buffer) then
      table.insert(valid_changes, change)
    end
  end
  -- Update current change index based on direction
  if direction == "next" then
    current_change_index = current_change_index + 1
  elseif direction == "prev" then
    current_change_index = current_change_index - 1
  end
  -- Ensure the index is within bounds
  current_change_index = math.max(1, math.min(current_change_index, #valid_changes))
  -- Move the cursor to the change
  local change = valid_changes[current_change_index]
  if change then
    vim.api.nvim_set_current_buf(change.buffer)
    vim.api.nvim_win_set_cursor(0, { change.change_number, 0 }) -- Move to the line of the change
  end
end
-- Define global commands for navigation
vim.api.nvim_create_user_command("NextChange", function()
  navigate_changes("next")
end, {})
vim.api.nvim_create_user_command("PrevChange", function()
  navigate_changes("prev")
end, {})
-- Load changes on startup
load_changes()
-- Save changes on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = save_changes,
})
