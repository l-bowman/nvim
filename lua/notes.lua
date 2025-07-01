local builtin = require("telescope.builtin")

-- Open my notes
local notes_dir = os.getenv("NOTES_DIR")
local push_timer = nil
local is_pushing = false -- Flag to indicate if a push is in progress
local is_shutting_down = false -- Flag to indicate if Neovim is shutting down

local function safe_git_command(git_cmd)
  if not notes_dir then
    return nil, "Notes directory not set"
  end
  -- Expand the path to handle ~ and relative paths
  local expanded_dir = vim.fn.expand(notes_dir)
  -- escape the dir path
  local escaped_dir = vim.fn.shellescape(expanded_dir)
  -- Construct the full command
  local full_cmd = "cd " .. escaped_dir .. " && " .. git_cmd
  -- Use systemlist to capture output as a list
  local output = vim.fn.systemlist(full_cmd)
  local success = vim.v.shell_error == 0
  -- If the command failed, join the output for a clearer error message
  if not success then
    return nil, "Command failed: " .. full_cmd .. "\nOutput: " .. table.concat(output, "\n")
  end
  return table.concat(output, "\n"), nil
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

  -- Check if it's a git repository
  if vim.fn.isdirectory(expanded_path .. "/.git") == 0 then
    print("The specified notes directory is not a git repository: " .. expanded_path)
    return false
  end

  return true
end

-- Example of improved error handling in PullNotes function
function PullNotes()
  if not check_notes_dir() then
    return
  end
  print("Pulling notes...")
  local _, pull_err = safe_git_command("git pull origin main")
  if pull_err then
    print("Error pulling notes: " .. pull_err)
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
    if not is_pushing and not is_shutting_down then
      StageCommitPushNotes()
    end
  end, { ["repeat"] = -1 }) -- Repeat indefinitely
end

-- Pull Notes when Neovim is opened (asynchronously to avoid blocking startup)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Start the timer immediately
    StartPushTimer()

    -- Not sure about pulling every time Neovim starts, so commented out for now
    -- Pull notes asynchronously after a short delay to avoid blocking startup
    -- vim.defer_fn(function()
    --   PullNotes()
    -- end, 1000) -- 1 second delay
  end,
})

function StageCommitPushNotes()
  local commit_message = "Auto-commit: Update notes" -- Customize this message as needed
  if not check_notes_dir() then
    return
  end

  local status_output, status_err = safe_git_command("git status --porcelain")
  if status_err then
    print("Error checking git status: " .. status_err)
    return
  end

  -- If there are changes, push them
  if status_output ~= "" then
    is_pushing = true
    print("Staging, committing, and pushing notes...")

    local _, add_err = safe_git_command("git add .")
    if add_err then
      print("Error staging files: " .. add_err)
      is_pushing = false
      return
    end

    local _, commit_err = safe_git_command("git commit -m '" .. commit_message .. "'")
    if commit_err then
      print("Error committing changes: " .. commit_err)
      is_pushing = false
      return
    end

    local _, push_err = safe_git_command("git push")
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
  -- Set shutdown flag to prevent timer conflicts
  is_shutting_down = true

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

    local status_output, status_err = safe_git_command("git status --porcelain")
    if status_err then
      print("PushOnExit: Error checking git status: " .. status_err)
      is_pushing = false
      return
    end

    -- If there are changes, push them
    if status_output ~= "" then
      print("PushOnExit: Changes detected, pushing...")

      local _, add_err = safe_git_command("git add .")
      if add_err then
        print("PushOnExit: Error staging files: " .. add_err)
        is_pushing = false
        return
      end

      local _, commit_err = safe_git_command("git commit -m '" .. commit_message .. "'")
      if commit_err then
        print("PushOnExit: Error committing changes: " .. commit_err)
        is_pushing = false
        return
      end

      local _, push_err = safe_git_command("git push")
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

-- Function to immediately edit a note file by name
function EditNote(filename)
  if not filename or filename == "" then
    print("Error: Please provide a filename to edit")
    return
  end

  if not check_notes_dir() then
    return
  end

  local expanded_dir = vim.fn.expand(notes_dir or "")
  -- Ensure we have a valid directory path
  if expanded_dir == "" then
    print("Error: Could not expand notes directory path")
    return
  end
  local file_path = expanded_dir .. "/" .. filename

  -- Check if file exists
  if vim.fn.filereadable(file_path) == 1 then
    -- File exists, open it
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    print("Opened note: " .. filename)
  else
    -- File doesn't exist, ask user if they want to create it
    local choice = vim.fn.confirm("File '" .. filename .. "' doesn't exist. Create it?", "&Yes\n&No", 1)
    if choice == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
      print("Created and opened new note: " .. filename)
    else
      print("Cancelled editing note: " .. filename)
    end
  end
end
