_G.ai_snippets = {
  dieselSnippet = "I need the up.sql and down.sql for a Diesel (already installed) migration and the command to create it. Here are some general things to know about how to write migrations according to our standards: Don't explicitly name constraints. Existing constraints are named in the following way: nameOfTable_nameOfColumn_check. For example, a column named example_id in a table called example_services might have a constraint called example_services_example_id_check. In general, if we need to work with constraints, it makes sense to remove existing constraints first and add new ones last to maintain data integrity and avoid conflicts. When working with removing old constraints, we don't want to use IF EXISTS since it can mask issues. We want to be careful about using IF EXISTS in general. We use PostgreSQL as our database, so ensure the SQL syntax is compatible with PostgreSQL. The migration should ",
}
-- Function to start a new ChatGPT session with a prompt
function _G.start_chatgpt_session_with_prompt(prompt)
  -- Open the ChatGPT window
  vim.cmd("ChatGPT")
  -- Use a timer to ensure the session is started before sending the prompt
  vim.defer_fn(function()
    -- Debugging: Notify that the function is attempting to start a new session
    vim.notify("Attempting to start a new ChatGPT session", vim.log.levels.INFO)
    -- Simulate Ctrl + n to start a new session
    vim.api.nvim_input("<C-n>")
    -- Send the prompt to the ChatGPT session
    vim.api.nvim_input(prompt)
  end, 500) -- Adjust the delay as needed
end
