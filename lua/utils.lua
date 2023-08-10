-- tmux crap
_G.toggle_tmux_pane = function()
  vim.cmd("!tmux display-message 'Test Message'")
end

_G.find_nearest_test = function()
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
  local filepath = vim.fn.expand("%:p")
  local filedir = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")

  -- Determine if a terminal split already exists
  local terminal_exists = false
  local win_ids = vim.api.nvim_list_wins()
  for _, win_id in ipairs(win_ids) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    if vim.api.nvim_buf_get_option(buf_id, "buftype") == "terminal" then
      terminal_exists = true
      vim.api.nvim_set_current_win(win_id) -- switch to terminal window
      break
    end
  end

  -- Determine the command to run
  local cmd_to_run = string.format(
    'cd %s && echo "Running Playwright Test . . ." && npx playwright test %s -g "%s"',
    filedir,
    filename,
    matched_text
  )

  -- If terminal exists, we switch to it and run the command, else we initialize a terminal with the command.
  if terminal_exists then
    -- vim.cmd('silent! call term_sendkeys("", "\\003' .. cmd_to_run .. '\\n")') -- CTRL-C to ensure we're at the command prompt, then send the command
    vim.cmd('silent! call term_sendkeys("", "\\003' .. vim.fn.escape(cmd_to_run, '"\\') .. '\\n")')
  else
    vim.cmd("vsplit | terminal " .. cmd_to_run) -- Start the terminal with the desired command
  end

  -- -- Display output to user
  -- if matched_text ~= "" then
  --   vim.api.nvim_out_write("Found: " .. matched_text .. "\n")
  --   vim.api.nvim_out_write("Directory Path: " .. filedir .. "\n")
  --   vim.api.nvim_out_write("File Name: " .. filename .. "\n")
  -- else
  --   vim.api.nvim_out_write("Pattern not found.\n")
  -- end
end
