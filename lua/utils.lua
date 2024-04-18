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
