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
  local running_message = repeat_count
      and string.format("Running nearest Playwright Test '%s' with a repeat count of %d...", matched_text, repeat_count)
    or string.format("Running nearest Playwright Test '%s'...", matched_text)

  if repeat_count then
    cmd = string.format(
      'cd %s && echo "%s" && npx playwright test --repeat-each=%d %s -g "%s"',
      filedir,
      running_message,
      repeat_count,
      filename,
      matched_text
    )
  else
    cmd = string.format(
      'cd %s && echo "%s" && npx playwright test %s -g "%s"',
      filedir,
      running_message,
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

  local running_message = repeat_count
      and string.format("Running all Playwright Tests in '%s' with a repeat count of %d...", filename, repeat_count)
    or string.format("Running all Playwright Tests in '%s'...", filename)

  local cmd_prefix = string.format('cd %s && echo "%s"', filedir, running_message)
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

-- This function checks if the cursor is within a given range.
local function is_within_range(cursor_line, start_line, end_line)
  return cursor_line >= start_line and cursor_line <= end_line
end

-- This function abstracts the common logic of finding a path based on a pattern.
local function find_pattern_path(pattern, start_line, end_line, cursor_line)
  local path_start_line, path_end_line
  local path

  for i = start_line, end_line do
    local line = tostring(vim.fn.getline(i))
    if line:find("test%-results/") then
      local next_line = tostring(vim.fn.getline(i + 1) or "")
      local combined_lines = line .. "\n" .. next_line
      path = combined_lines:match(pattern)
      path_start_line = i

      if path then
        path_end_line = path:find("\n") and i + 1 or i
      end

      -- If we found a path and the cursor is within its range, break the loop.
      if path and is_within_range(cursor_line, path_start_line, path_end_line) then
        break
      else
        path = nil
      end
    end
  end

  return path, path_start_line, path_end_line
end

_G.play_test_video = function()
  local pattern = "test%-results/.+%.webm"
  local start_line = vim.fn.line("w0")
  local end_line = vim.fn.line("w$")
  local cursor_line = vim.fn.line(".")

  local path, path_start_line, path_end_line = find_pattern_path(pattern, start_line, end_line, cursor_line)

  if not path then
    print("Path not found!")
    return
  end

  local root_path = vim.fn.getcwd()
  local open_cmd

  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"
  else
    print("Unsupported OS for this operation!")
    return
  end

  -- Use find to locate the file and open the first match
  local cmd = string.format("cd %s && %s $(find . -type f | grep '%s' | head -1)", root_path, open_cmd, path)
  vim.fn.system(cmd)
end

_G.play_test_trace = function()
  local pattern = "test%-results/.+%.zip"
  local start_line = vim.fn.line("w0")
  local end_line = vim.fn.line("w$")
  local cursor_line = vim.fn.line(".")

  local path, path_start_line, path_end_line = find_pattern_path(pattern, start_line, end_line, cursor_line)

  if not path then
    print("Path is nil!")
    return
  end

  local root_path = vim.fn.getcwd()

  -- We'll use `find` to locate the trace directory.
  path = path:gsub("\n", "") -- Remove any newline from the output

  local find_cmd =
    string.format("find %s -type d -name 'test-results' -exec find {} -type f -name 'trace.zip' \\;", root_path)
  local trace_directory = vim.fn.system(find_cmd .. " | grep -F '" .. path .. "' | xargs -I{} dirname {} | head -1")

  if not trace_directory or trace_directory == "" then
    print("Directory containing the trace file not found!")
    return
  end

  trace_directory = trace_directory:gsub("\n", "") -- Remove any newline from the output

  -- Use the command to open the trace
  local cmd = string.format("cd %s && npx playwright show-trace %s", trace_directory, path)
  vim.fn.system(cmd)
end

_G.close_test_terminal = function()
  close_existing_test_terminals()
end

-- Close any buffer named "PlaywrightTesting"
_G.close_playwright_buffer = function()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf)
    if string.find(name, "PlaywrightTesting") then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

vim.cmd([[autocmd VimEnter * lua close_playwright_buffer()]])
