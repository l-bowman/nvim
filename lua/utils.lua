-- tmux crap
_G.toggle_tmux_pane = function()
  vim.cmd("!tmux display-message 'Test Message'")
end

-- PLAYWRIGHT CRAP -> Future plugin
local last_test_command = nil

-- Helper functions:

local function get_nearest_test_pattern()
  return [[test("\([^"]*\)"]]
end

local function get_current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function find_nearest_test_position(current_line)
  local pattern = get_nearest_test_pattern()
  local prev_pos = vim.fn.searchpos(pattern, "bn")
  local next_pos = vim.fn.searchpos(pattern, "n")

  local semicolon_pos = vim.fn.searchpos(";", "n")
  local valid_forward_search = not (semicolon_pos[1] > 0 and (next_pos[1] == 0 or semicolon_pos[1] < next_pos[1]))

  local chosen_line = prev_pos[1]
  if
    prev_pos[1] == 0
    or (next_pos[1] > 0 and valid_forward_search and next_pos[1] - current_line < current_line - prev_pos[1])
  then
    chosen_line = next_pos[1]
  end

  return chosen_line
end

local function get_test_name_from_line(line_number)
  local pattern = get_nearest_test_pattern()
  local matched_text = vim.fn.matchstr(vim.fn.getline(line_number), pattern, "\\1")
  return matched_text:match('"(.-)"')
end

local function get_current_context()
  local original_win_id = vim.api.nvim_get_current_win()
  local original_buf_id = vim.api.nvim_get_current_buf()
  local filedir = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")
  return original_win_id, original_buf_id, filedir, filename
end

local function construct_cmd(filedir, repeat_count, filename, matched_text)
  local cmd
  if repeat_count then
    cmd = string.format(
      'cd %s && echo "Running Playwright Test . . ." && npx playwright test --repeat-each=%d %s -g "%s"',
      filedir,
      repeat_count,
      filename,
      matched_text
    )
  else
    cmd = string.format(
      'cd %s && echo "Running Playwright Test . . ." && npx playwright test %s -g "%s"',
      filedir,
      filename,
      matched_text
    )
  end

  -- Set the last test command
  last_test_command = cmd
  return cmd
end

local function close_existing_test_terminals()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local buffer_name = vim.api.nvim_buf_get_name(bufnr)
    local buf_type = vim.api.nvim_buf_get_option(bufnr, "buftype")

    if buf_type == "terminal" then
      local term_name = vim.fn.fnamemodify(buffer_name, ":t")
      if term_name == "PlaywrightTesting" then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end
  end
end

local function execute_in_terminal(cmd)
  vim.cmd("vsplit | terminal " .. cmd)
  vim.cmd("file PlaywrightTesting")
end

-- Main functions:

_G.run_nearest_test = function(repeat_count)
  local original_win_id, original_buf_id, filedir, filename = get_current_context()

  local current_line = get_current_line_number()
  local chosen_line = find_nearest_test_position(current_line)

  local matched_text = chosen_line > 0 and get_test_name_from_line(chosen_line) or ""

  local cmd_to_run = construct_cmd(filedir, repeat_count, filename, matched_text)
  close_existing_test_terminals()
  execute_in_terminal(cmd_to_run)

  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

_G.run_all_tests = function(repeat_count)
  local original_win_id, original_buf_id, filedir, filename = get_current_context()

  local cmd_prefix = string.format('cd %s && echo "Running Playwright Test . . ."', filedir)
  local cmd_suffix = repeat_count and string.format("npx playwright test --repeat-each=%d %s", repeat_count, filename)
    or string.format("npx playwright test %s", filename)
  local cmd_to_run = cmd_prefix .. " && " .. cmd_suffix

  close_existing_test_terminals()
  execute_in_terminal(cmd_to_run)

  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

_G.run_last_test = function()
  if last_test_command then
    local original_win_id, original_buf_id = get_current_context()

    close_existing_test_terminals()
    execute_in_terminal(last_test_command)

    vim.api.nvim_set_current_win(original_win_id)
    vim.api.nvim_set_current_buf(original_buf_id)
  else
    print("No tests have been run yet.")
  end
end

_G.close_test_terminal = function()
  close_existing_test_terminals()
end
