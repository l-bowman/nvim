-- tmux crap
_G.toggle_tmux_pane = function()
  vim.cmd("!tmux display-message 'Test Message'")
end

-- playwright crap
_G.run_nearest_test = function()
  -- Store the current window and buffer ID
  local original_win_id = vim.api.nvim_get_current_win()
  local original_buf_id = vim.api.nvim_get_current_buf()

  local pattern = [[test("\([^"]*\)"]]

  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Search backwards
  local prev_pos = vim.fn.searchpos(pattern, "bn")

  -- Search forwards
  local next_pos = vim.fn.searchpos(pattern, "n")

  local semicolon_pos = vim.fn.searchpos(";", "n")

  -- Check if a semicolon is encountered before the next test() pattern
  local valid_forward_search = true
  if semicolon_pos[1] > 0 and (next_pos[1] == 0 or semicolon_pos[1] < next_pos[1]) then
    valid_forward_search = false
  end

  local chosen_line = 0
  if
    prev_pos[1] == 0
    or (next_pos[1] > 0 and valid_forward_search and next_pos[1] - current_line < current_line - prev_pos[1])
  then
    chosen_line = next_pos[1]
  else
    chosen_line = prev_pos[1]
  end

  -- Fetch the matched text
  local matched_text = ""
  if chosen_line > 0 then
    matched_text = vim.fn.matchstr(vim.fn.getline(chosen_line), pattern, "\\1")
    matched_text = matched_text:match('"(.-)"')
  end

  -- Retrieve the file path
  local filedir = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")

  local cmd_to_run = string.format(
    'cd %s && echo "Running Playwright Test . . ." && npx playwright test %s -g "%s"',
    filedir,
    filename,
    matched_text
  )

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

  vim.cmd("vsplit | terminal " .. cmd_to_run) -- Start the terminal with the desired command
  vim.cmd("file " .. "PlaywrightTesting") -- Set the name of the terminal buffer
  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

-- add function to test entire file instead of just the nearest test
_G.run_all_tests = function()
  -- Store the current window and buffer ID
  local original_win_id = vim.api.nvim_get_current_win()
  local original_buf_id = vim.api.nvim_get_current_buf()

  -- Retrieve the file path
  local filedir = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")

  local cmd_to_run =
    string.format('cd %s && echo "Running Playwright Test . . ." && npx playwright test %s', filedir, filename)

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

  vim.cmd("vsplit | terminal " .. cmd_to_run) -- Start the terminal with the desired command
  vim.cmd("file " .. "PlaywrightTesting") -- Set the name of the terminal buffer
  vim.api.nvim_set_current_win(original_win_id)
  vim.api.nvim_set_current_buf(original_buf_id)
end

_G.close_test_terminal = function()
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
