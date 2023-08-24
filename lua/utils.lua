-- tmux crap
_G.toggle_tmux_pane = function()
  vim.cmd("!tmux display-message 'Test Message'")
end

-- PLAYWRIGHT CRAP -> Future plugin
local playwright = {}

--------------------------
-- Plugin Initialization
--------------------------
playwright.config = {
  test_directories = {
    "~/Documents/dev/monorepo/portals/management/tests",
    "/absolute/path/to/your/tests2",
  },
}
local last_test_command = nil

-- Configuration table for the plugin
_G.playwright_test_config = _G.playwright_test_config or {}

--------------------------
-- Utility Functions
--------------------------
local function reset_editor_context(original_win_id, original_buf_id)
  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

local function get_nearest_test_pattern()
  return [[test("\([^"]*\)"]]
end

local function get_current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function find_nearest_test_line(current_line)
  local pattern = get_nearest_test_pattern()

  -- Check if the current line matches the test pattern
  if vim.fn.matchstr(vim.fn.getline(current_line), pattern) ~= "" then
    return current_line
  end

  -- Special handling for blank line: Check if there's a test pattern anywhere below up to a semicolon
  if vim.fn.trim(vim.fn.getline(current_line)) == "" then
    local line_below = vim.fn.searchpos(pattern, "n")
    local semicolon_pos = vim.fn.search(";", "ncW", current_line)

    if line_below[1] ~= 0 and (semicolon_pos == 0 or semicolon_pos > line_below[1]) then
      return line_below[1]
    end
  end

  -- Search downwards from the cursor position for the test pattern
  local next_pos = vim.fn.searchpos(pattern, "n")

  -- If the downward search did not find any matches or a semicolon is found before the next test pattern
  if next_pos[1] == 0 or vim.fn.search(";", "ncW", current_line) < next_pos[1] then
    -- Search upwards from the cursor position for the test pattern
    local prev_pos = vim.fn.searchpos(pattern, "b")
    return prev_pos[1]
  else
    return next_pos[1]
  end
end

local function get_test_name_from_line(line_number)
  local pattern = get_nearest_test_pattern()
  local matched_text = vim.fn.matchstr(vim.fn.getline(line_number), pattern, "\\1")
  return matched_text:match('"(.-)"')
end

local function get_current_editor_context()
  local original_win_id = vim.api.nvim_get_current_win()
  local original_buf_id = vim.api.nvim_get_current_buf()
  local file_directory = vim.fn.expand("%:p:h")
  local file_name = vim.fn.expand("%:t")
  return original_win_id, original_buf_id, file_directory, file_name
end

local function build_test_command(file_directory, repeat_count, file_name, matched_text, debug)
  local cmd
  local running_message = repeat_count
      and string.format("Running nearest Playwright Test '%s' with a repeat count of %d...", matched_text, repeat_count)
    or string.format("Running nearest Playwright Test '%s'...", matched_text)

  local debug_flag = debug and "--debug" or ""

  if repeat_count then
    cmd = string.format(
      'cd %s && echo "%s" && npx playwright test %s --reporter=html --repeat-each=%d %s -g "%s"',
      file_directory,
      running_message,
      debug_flag,
      repeat_count,
      file_name,
      matched_text
    )
  else
    cmd = string.format(
      'cd %s && echo "%s" && npx playwright test %s %s --reporter=html -g "%s"',
      file_directory,
      running_message,
      debug_flag,
      file_name,
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

-- Fetch or prompt for the test directory
local function select_test_directory()
  local test_dirs = playwright.config.test_directories
  if not test_dirs or #test_dirs == 0 then
    print("Please configure the test directories.")
    return nil
  elseif #test_dirs == 1 then
    return test_dirs[1]
  else
    local display_options = { "Select a test directory:" }
    for i, dir in ipairs(test_dirs) do
      table.insert(display_options, string.format("%d. %s", i, dir))
    end

    local choice = vim.fn.inputlist(display_options)
    if choice < 1 or choice > #test_dirs then
      print("Invalid selection.")
      return nil
    end
    return test_dirs[choice]
  end
end

--------------------------
-- Main Functions
--------------------------
--Execute all tests
function playwright.run_all_tests_in_directory(repeat_count)
  local test_dir = select_test_directory() -- fetch the test directory from config or user input
  if not test_dir then
    return
  end -- If no valid directory, exit the function

  local cmd = "cd " .. test_dir .. " && npx playwright test --reporter=html"

  -- If repeat_count is provided, add it to the command
  if repeat_count and tonumber(repeat_count) then
    cmd = cmd .. " --repeat-each=" .. tostring(repeat_count)
  end

  -- Close any existing test terminals and execute the command in a new terminal (assuming we're in Neovim)
  close_existing_test_terminals()
  execute_in_terminal(cmd)

  -- Restore the original window and buffer context
  local original_win_id, original_buf_id = get_current_editor_context()
  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.run_nearest_test(repeat_count, debug)
  local original_win_id, original_buf_id, file_directory, file_name = get_current_editor_context()

  local current_line = get_current_line_number()
  local chosen_line = find_nearest_test_line(current_line)

  local matched_text = chosen_line > 0 and get_test_name_from_line(chosen_line) or ""

  local cmd_to_run = build_test_command(file_directory, repeat_count, file_name, matched_text, debug)
  close_existing_test_terminals()
  execute_in_terminal(cmd_to_run)

  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.debug_nearest_test(repeat_count)
  playwright.run_nearest_test(repeat_count, true)
end

function playwright.run_all_tests(repeat_count)
  local original_win_id, original_buf_id, file_directory, file_name = get_current_editor_context()

  local running_message = repeat_count
      and string.format("Running all Playwright Tests in '%s' with a repeat count of %d...", file_name, repeat_count)
    or string.format("Running all Playwright Tests in '%s'...", file_name)

  local cmd_prefix = string.format('cd %s && echo "%s"', file_directory, running_message)
  local cmd_suffix = repeat_count
      and string.format("npx playwright test --reporter=html --repeat-each=%d %s", repeat_count, file_name)
    or string.format("npx playwright test %s --reporter=html", file_name)
  local cmd_to_run = cmd_prefix .. " && " .. cmd_suffix

  close_existing_test_terminals()
  execute_in_terminal(cmd_to_run)

  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.run_last_test()
  if last_test_command then
    local original_win_id, original_buf_id = get_current_editor_context()

    close_existing_test_terminals()
    execute_in_terminal(last_test_command)

    reset_editor_context(original_win_id, original_buf_id)
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

function playwright.open_test_video()
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

function playwright.open_test_trace()
  local pattern = "test%-results/.+%.zip"
  local cursor_line = vim.fn.line(".")

  local path = find_pattern_path(pattern, vim.fn.line("w0"), vim.fn.line("w$"), cursor_line)

  if not path then
    print("Path is nil!")
    return
  end

  local root_path = vim.fn.getcwd()
  path = path:gsub("\n", "") -- Remove any newline from the output

  local find_cmd =
    string.format("find %s -type d -name 'test-results' -exec find {} -type f -name 'trace.zip' \\;", root_path)

  -- Function to handle the callback from the asynchronous job
  local on_job_exit = function(_, find_exit_code)
    if find_exit_code ~= 0 then
      print("Error finding the trace directory!")
      return
    end

    local trace_directory =
      vim.fn.systemlist(find_cmd .. " | grep -F '" .. path .. "' | xargs -I{} dirname {} | head -1")[1]
    if not trace_directory or trace_directory == "" then
      print("Directory containing the trace file not found!")
      return
    end

    trace_directory = trace_directory:gsub("\n", "") -- Remove any newline from the output

    -- Use the command to open the trace
    local cmd = string.format("cd %s && npx playwright show-trace %s", trace_directory, path)
    vim.fn.jobstart(cmd, {
      on_exit = function(_, play_exit_code)
        if play_exit_code ~= 0 then
          print("Error executing the playwright command!")
        end
      end,
    })
  end

  -- Start the job asynchronously
  vim.fn.jobstart(find_cmd, { on_exit = on_job_exit })
end

function playwright.close_test_terminal()
  close_existing_test_terminals()
end

-- Close any buffer named "PlaywrightTesting"
function playwright.close_playwright_buffer()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf)
    if string.find(name, "PlaywrightTesting") then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

-- Set up the global namespace
_G.playwright = playwright

-- Autocommands
vim.cmd([[autocmd VimEnter * lua playwright.close_playwright_buffer()]])
