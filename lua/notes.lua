local builtin = require("telescope.builtin")

-- Open my notes
local notes_dir = os.getenv("NOTES_DIR")
local push_timer = nil
local is_pushing = false -- Flag to indicate if a push is in progress

-- Helper function to safely execute shell commands with proper path escaping
local function safe_system(cmd)
  if not notes_dir then
    return nil, "Notes directory not set"
  end
  -- Expand and escape the notes directory path to handle special characters
  local expanded_dir = vim.fn.expand(notes_dir)
  local escaped_dir = vim.fn.shellescape(expanded_dir)

  -- Use string.gsub with pattern escaping to handle special characters
  local pattern = "cd " .. notes_dir:gsub("([^%w])", "%%%1")
  local full_cmd = cmd:gsub(pattern, "cd " .. escaped_dir)

  local output = vim.fn.system(full_cmd)
  local success = vim.v.shell_error == 0
  return output, success and nil or ("Command failed: " .. full_cmd)
end

local function check_notes_dir()
  if not notes_dir then
    print("Notes directory is not set. Please set the NOTES_DIR environment variable.")
    return false
  end

  -- Expand the path to handle ~ and relative paths
  local expanded_path = vim.fn.expand(notes_dir)

  -- Check if directory exists
  if vim.fn.isdirectory(expanded_path) == 0 then
    print("Notes directory does not exist: " .. expanded_path)
    return false
  end

  return true
end

function PullNotes()
  if not check_notes_dir() then
    return
  end

  print("Pulling notes...")
  local pull_output = safe_system("cd " .. notes_dir .. " && git pull origin main")

  if vim.v.shell_error ~= 0 then
    print("Error pulling notes: " .. pull_output)
    return false
  else
    print("Notes pulled successfully.")
    return true
  end
end

-- Function to stop the current timer if it exists
local function stop_push_timer()
  if push_timer then
    vim.fn.timer_stop(push_timer)
    push_timer = nil
  end
end

-- Function to start the timer for pushing changes
function StartPushTimer()
  -- Stop any existing timer first
  stop_push_timer()

  -- Start a new timer
  push_timer = vim.fn.timer_start(300000, function() -- 300000 milliseconds = 5 minutes
    if not is_pushing then
      StageCommitPushNotes()
    end
  end, { ["repeat"] = -1 }) -- Repeat indefinitely
end

-- Pull Notes when Neovim is opened
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if PullNotes() then -- Only start timer if pull was successful
      StartPushTimer()
    end
  end,
})

function StageCommitPushNotes()
  local commit_message = "Auto-commit: Update notes" -- Customize this message as needed
  if not check_notes_dir() then
    return
  end

  local status_output, status_err = safe_system("cd " .. notes_dir .. " && git status --porcelain")
  if status_err then
    print("Error checking git status: " .. status_err)
    return
  end

  -- If there are changes, push them
  if status_output ~= "" then
    is_pushing = true
    print("Staging, committing, and pushing notes...")

    local _, add_err = safe_system("cd " .. notes_dir .. " && git add .")
    if add_err then
      print("Error staging files: " .. add_err)
      is_pushing = false
      return
    end

    local _, commit_err = safe_system("cd " .. notes_dir .. " && git commit -m '" .. commit_message .. "'")
    if commit_err then
      print("Error committing changes: " .. commit_err)
      is_pushing = false
      return
    end

    local _, push_err = safe_system("cd " .. notes_dir .. " && git push")
    if push_err then
      print("Error pushing notes: " .. push_err)
    else
      print("Notes changes pushed successfully.")
    end
    is_pushing = false -- Reset the flag after the push is complete
  else
    print("No changes to push.")
  end
end

function PushOnExit()
  -- Stop the timer to prevent conflicts
  stop_push_timer()

  print("PushOnExit: Attempting to push notes before exit...")

  if not is_pushing then -- Only push if not already pushing
    -- Set flag to prevent timer conflicts
    is_pushing = true

    -- Call push function directly and wait for completion
    local commit_message = "Auto-commit: Update notes on exit"
    if not check_notes_dir() then
      is_pushing = false
      return
    end

    local status_output, status_err = safe_system("cd " .. notes_dir .. " && git status --porcelain")
    if status_err then
      print("PushOnExit: Error checking git status: " .. status_err)
      is_pushing = false
      return
    end

    -- If there are changes, push them
    if status_output ~= "" then
      print("PushOnExit: Changes detected, pushing...")

      local _, add_err = safe_system("cd " .. notes_dir .. " && git add .")
      if add_err then
        print("PushOnExit: Error staging files: " .. add_err)
        is_pushing = false
        return
      end

      local _, commit_err = safe_system("cd " .. notes_dir .. " && git commit -m '" .. commit_message .. "'")
      if commit_err then
        print("PushOnExit: Error committing changes: " .. commit_err)
        is_pushing = false
        return
      end

      local _, push_err = safe_system("cd " .. notes_dir .. " && git push")
      if push_err then
        print("PushOnExit: Error pushing notes: " .. push_err)
      else
        print("PushOnExit: Notes pushed successfully!")
      end
    else
      print("PushOnExit: No changes to push.")
    end

    is_pushing = false
  else
    print("PushOnExit: Push already in progress, skipping.")
  end
end

-- Backup notes when Neovim is closed
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = PushOnExit,
})

function FindNotesFiles()
  if not check_notes_dir() then
    return
  end
  builtin.find_files({
    prompt_title = "Notes",
    cwd = notes_dir,
  })
end

function LiveGrepNotes()
  if not check_notes_dir() then
    return
  end
  builtin.live_grep({
    prompt_title = "Live Grep Notes",
    cwd = notes_dir,
  })
end
