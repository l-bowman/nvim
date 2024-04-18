local playwright = {
  config = {
    test_directories = {
      "~/Documents/dev/monorepo/portals/management/tests",
      "/absolute/path/to/your/tests2",
    },
    reporter = "html",
    retries = 0,
  },
}

local function is_within_range(cursor_line, start_line, end_line)
  return cursor_line >= start_line and cursor_line <= end_line
end

local function find_pattern_path(start_line, end_line, cursor_line, pattern)
  for i = start_line, end_line do
    local line = vim.fn.getline(i)
    if line:find("test%-results/") then
      local next_line = vim.fn.getline(i + 1) or ""
      local path = (line .. "\n" .. next_line):match(pattern)

      if path and is_within_range(cursor_line, i, path:find("\n") and i + 1 or i) then
        return path, i, path:find("\n") and i + 1 or i
      end
    end
  end

  return nil, nil, nil
end

local function reset_editor_context(original_win_id, original_buf_id)
  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

local function get_editor_context()
  return vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), vim.fn.expand("%:p:h"), vim.fn.expand("%:t")
end

local function get_test_pattern()
  return [[test("\([^"]*\)"]]
end

local function get_cursor_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function find_nearest_test_line(cursor_line)
  local test_pattern = get_test_pattern()

  if vim.fn.matchstr(vim.fn.getline(cursor_line), test_pattern) ~= "" then
    return cursor_line
  end

  if vim.fn.trim(vim.fn.getline(cursor_line)) == "" then
    local line_below = vim.fn.searchpos(test_pattern, "n")
    local semicolon_pos = vim.fn.search(";", "ncW", cursor_line)

    if line_below[1] ~= 0 and (semicolon_pos == 0 or semicolon_pos > line_below[1]) then
      return line_below[1]
    end
  end

  local next_pos = vim.fn.searchpos(test_pattern, "n")

  if next_pos[1] == 0 or vim.fn.search(";", "ncW", cursor_line) < next_pos[1] then
    return vim.fn.searchpos(test_pattern, "b")[1]
  end

  return next_pos[1]
end

local function get_test_name_from_line(line_number)
  return vim.fn.matchstr(vim.fn.getline(line_number), get_test_pattern(), "\\1"):match('"(.-)"')
end

local function build_test_command(file_directory, repeat_count, file_name, matched_text, debug)
  local running_message = repeat_count
      and string.format("Running nearest Playwright Test '%s' with a repeat count of %d...", matched_text, repeat_count)
    or string.format("Running nearest Playwright Test '%s'...", matched_text)

  local debug_flag = debug and "--debug" or ""
  local repeat_flag = repeat_count and string.format("--repeat-each=%d", repeat_count) or ""

  local test_command = string.format(
    'cd %s && echo "%s" && npx playwright test %s --retries=%d --reporter=%s %s %s -g "%s"',
    file_directory,
    running_message,
    debug_flag,
    playwright.config.retries,
    playwright.config.reporter,
    repeat_flag,
    file_name,
    matched_text
  )
  playwright.last_test_command = test_command
  return test_command
end

local function close_test_terminals()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      local term_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
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
    if choice == 0 then
      print("Directory selection canceled.")
      return nil
    elseif choice < 1 or choice > #test_dirs then
      print("Invalid selection.")
      return nil
    end
    return test_dirs[choice]
  end
end

function playwright.run_all_tests_in_directory(repeat_count)
  local test_dir = select_test_directory()
  if not test_dir then
    return
  end

  local cmd = string.format(
    "cd %s && npx playwright test --retries=%d --reporter=%s",
    test_dir,
    playwright.config.retries,
    playwright.config.reporter
  )

  if repeat_count and tonumber(repeat_count) then
    cmd = cmd .. " --repeat-each=" .. tostring(repeat_count)
  end

  close_test_terminals()
  execute_in_terminal(cmd)

  local original_win_id, original_buf_id = get_editor_context()
  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.run_nearest_test(repeat_count, debug)
  local original_win_id, original_buf_id, file_directory, file_name = get_editor_context()

  local cursor_line = get_cursor_line()
  local chosen_line = find_nearest_test_line(cursor_line)

  local matched_text = chosen_line > 0 and get_test_name_from_line(chosen_line) or ""

  local cmd_to_run = build_test_command(file_directory, repeat_count, file_name, matched_text, debug)
  close_test_terminals()
  execute_in_terminal(cmd_to_run)

  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.debug_nearest_test(repeat_count)
  playwright.run_nearest_test(repeat_count, true)
end

function playwright.run_all_tests(repeat_count)
  local original_win_id, original_buf_id, file_directory, file_name = get_editor_context()

  local running_message = repeat_count
      and string.format("Running all Playwright Tests in '%s' with a repeat count of %d...", file_name, repeat_count)
    or string.format("Running all Playwright Tests in '%s'...", file_name)

  local repeat_flag = repeat_count and string.format("--repeat-each=%d", repeat_count) or ""

  local cmd_to_run = string.format(
    'cd %s && echo "%s" && npx playwright test %s --retries=%d --reporter=%s %s',
    file_directory,
    running_message,
    repeat_flag,
    playwright.config.retries,
    playwright.config.reporter,
    file_name
  )

  close_test_terminals()
  execute_in_terminal(cmd_to_run)

  reset_editor_context(original_win_id, original_buf_id)
end

function playwright.run_last_test()
  if playwright.last_test_command then
    local original_win_id, original_buf_id = get_editor_context()

    close_test_terminals()
    execute_in_terminal(playwright.last_test_command)

    reset_editor_context(original_win_id, original_buf_id)
  else
    print("No tests have been run yet.")
  end
end

function playwright.open_test_video()
  local pattern = "test%-results/.+%.webm"
  local cursor_line = vim.fn.line(".")

  local path, path_start_line, path_end_line =
    find_pattern_path(vim.fn.line("w0"), vim.fn.line("w$"), cursor_line, pattern)

  if not path then
    print("Path not found!")
    return
  end

  local root_path = vim.fn.getcwd()
  local open_cmd = vim.fn.has("mac") == 1 and "open" or vim.fn.has("unix") == 1 and "xdg-open" or nil

  if not open_cmd then
    print("Unsupported OS for this operation!")
    return
  end

  local cmd = string.format("cd %s && %s $(find . -type f | grep '%s' | head -1)", root_path, open_cmd, path)
  vim.fn.system(cmd)
end

function playwright.open_test_trace()
  local pattern = "test%-results/.+%.zip"
  local cursor_line = vim.fn.line(".")

  local path = find_pattern_path(vim.fn.line("w0"), vim.fn.line("w$"), cursor_line, pattern)

  if not path then
    print("Path is nil!")
    return
  end

  local root_path = vim.fn.getcwd()
  path = path:gsub("\n", "")

  local find_cmd =
    string.format("find %s -type d -name 'test-results' -exec find {} -type f -name 'trace.zip' \\;", root_path)

  local on_job_exit = function(_, find_exit_code)
    if find_exit_code ~= 0 then
      print("Error finding the trace directory!")
      return
    end

    local trace_directory_list =
      vim.fn.systemlist(find_cmd .. " | grep -F '" .. path .. "' | xargs -I{} dirname {} | head -1")
    if #trace_directory_list == 0 then
      print("Directory containing the trace file not found!")
      return
    end

    local trace_directory = trace_directory_list[1]:gsub("\n", "")

    local cmd = string.format("cd %s && npx playwright show-trace %s", trace_directory, path)
    vim.fn.jobstart(cmd, {
      on_exit = function(_, play_exit_code)
        if play_exit_code ~= 0 then
          print("Error executing the playwright command!")
        end
      end,
    })
  end

  vim.fn.jobstart(find_cmd, { on_exit = on_job_exit })
end

function playwright.close_test_terminal()
  close_test_terminals()
end

function playwright.close_playwright_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):find("PlaywrightTesting") then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

_G.playwright = playwright

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    playwright.close_playwright_buffer()
  end,
})
