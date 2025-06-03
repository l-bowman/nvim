_G.sessionSaveAndFormatWrite = function()
  -- vim.cmd("SessionSave")
  -- vim.cmd("w | FormatWrite")
  vim.cmd("w")
end

function SmartImportPasteAndLint()
  -- Call SmartImportPaste() function
  SmartImportPaste()

  -- Call sessionSaveAndFormatWrite() function
  sessionSaveAndFormatWrite()

  -- Get the current file path
  local file_path = vim.fn.expand("%:p")

  -- Construct the ESLint command
  local eslint_cmd = string.format("!cd portals/management && npx eslint --fix %s && cd -", file_path)

  -- Execute the ESLint command
  vim.cmd(eslint_cmd)

  -- Display a message indicating the completion of the function
  vim.api.nvim_echo({ { "Special paste and lint complete" } }, true, {})
end

function _G.paste_figma_color_variable(mode)
  local clip_content = vim.fn.getreg("+") -- get the content of the system clipboard
  local variable_name = string.gsub(clip_content, "^.+/", "") -- remove everything before and including '/'
  local prefix = ""

  if mode == "background" then -- if the mode is background, change the prefix
    prefix = "background-color: "
  elseif mode == "color" then -- if the mode is color, set the prefix
    prefix = "color: "
  elseif mode == "bg-color" or mode == "text-color" then -- if the mode is bg-color or text-color, make the necessary modifications
    variable_name = string.gsub(variable_name, "^%$", "") -- remove everything before and including '$'
    variable_name = mode == "bg-color" and "bg-" .. variable_name or "text-" .. variable_name -- prepend 'bg-' or 'text-', depending on the mode

    local split_location = variable_name:find("_[^_]*$")
    if split_location then
      local part1 = variable_name:sub(1, split_location - 1)
      local part2 = variable_name:sub(split_location + 1)
      part1 = string.gsub(part1, "_", "-") -- replace underscores with '-'
      variable_name = part1 .. "-" .. part2
    else
      variable_name = string.gsub(variable_name, "_", "-") -- replace underscores with '-'
    end
  end

  if variable_name ~= "" then
    variable_name = prefix .. variable_name -- prepend prefix
    if mode == "color" or mode == "background" then -- if mode is color or background, append ';'
      variable_name = variable_name .. ";"
    end
    vim.fn.setreg("0", variable_name) -- set the modified content back into the '0' register
  end

  if mode ~= "bg-color" and mode ~= "text-color" then
    vim.cmd("normal! o") -- Start a new line only if the mode is not 'bg-color' or 'text-color'
  end
  vim.cmd('normal! "0p') -- paste the content of the '0' register
end

_G.diffview_file_history = function()
  -- Get the absolute path of the current file
  local abs_path = vim.api.nvim_buf_get_name(0)

  -- Get the working directory path
  local cwd = vim.fn.getcwd()

  -- Find the relative path
  local relative_path = abs_path:match("^" .. cwd .. "/(.*)") or abs_path

  -- Execute the DiffviewFileHistory command with the relative path
  vim.cmd("DiffviewFileHistory " .. relative_path)
end

function _G.checkout_new_branch()
  local command = [[!git checkout -b lb/]]
  -- The keys function works by sending a string as if you typed it
  -- So first go to normal mode with <Esc>
  -- Then start the command with :
  -- Then insert our command
  -- But don't press enter (that's why we leave out the <CR>)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>:" .. command, true, false, true), "n", false)
end

function _G.search_changed_files()
  -- Get the list of changed files
  local results = vim.fn.systemlist("git diff --name-only master...HEAD")
  -- Check if there are any results
  if #results == 0 then
    print("No changed files found.")
    return
  end
  -- Use Telescope to open the list of changed files
  require("telescope.builtin").find_files({
    prompt_title = "Changed Files",
    cwd = vim.loop.cwd(),
    search_dirs = results,
  })
end

function _G.live_grep_changed_files()
  local results = vim.fn.systemlist("git diff --name-only master...HEAD")
  if #results == 0 then
    print("No changed files found.")
    return
  end
  require("telescope.builtin").live_grep({
    prompt_title = "Grep Changed Files",
    search_dirs = results,
  })
end

function _G.populate_quickfix_with_changed_files()
  local results = vim.fn.systemlist("git diff --numstat master...HEAD")
  if #results == 0 then
    print("No changed files found.")
    return
  end
  local quickfix_list = {}
  for _, line in ipairs(results) do
    local added, deleted, file = line:match("(%d+)%s+(%d+)%s+(.+)")
    if added and deleted and file then
      local added_num = tonumber(added)
      local deleted_num = tonumber(deleted)
      local changeset_size = added_num + deleted_num
      local text = string.format("Added: %s, Deleted: %s", added, deleted)
      table.insert(quickfix_list, { filename = file, text = text, changeset_size = changeset_size })
    end
  end
  table.sort(quickfix_list, function(a, b)
    return a.changeset_size > b.changeset_size
  end)
  for _, item in ipairs(quickfix_list) do
    item.changeset_size = nil
  end
  vim.fn.setqflist(quickfix_list, "r")
  vim.cmd("copen")
end

local function qf_toggle()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

return {
  {
    "folke/which-key.nvim",

    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
          },
        },
        win = {
          border = "single", -- none, single, double, shadow
          padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
        },
      })
      wk.add({
        {
          { "<leader>A", group = "Auto Sessions" },
          { "<leader>AS", "<cmd>SessionSave<cr>", desc = "Save session" },
          { "<leader>Ad", "<cmd>SessionDelete<cr>", desc = "Delete session" },
          { "<leader>Ar", "<cmd>%bd!<CR><cmd>SessionRestore<cr>", desc = "Restore session" },
          { "<leader>As", "<cmd>SessionSearch<cr>", desc = "Search sessions" },

          { "<leader>C", group = "Console Commands" },
          { "<leader>CC", "<cmd>bufdo bd | :cd ~/.config/nvim<cr>", desc = "Open NVIM Config" },
          { "<leader>CD", "<cmd>!rm -f ~/.local/share/nvim/sessions/*<cr>", desc = "Remove All Sessions" },
          { "<leader>Ca", "<cmd>2TermExec cmd='just build-apollo-full'<cr>", desc = "Build Apollo Full" },
          {
            "<leader>Cc",
            "<cmd>!cd portals/customer && npx eslint --fix %:p && cd -<cr>",
            desc = "Lint Fix File - Customer",
          },
          { "<leader>Cg", "<cmd>2TermExec cmd='just clean-git-branches'<cr>", desc = "Clean Git Branches" },
          {
            "<leader>Cm",
            "<cmd>!cd portals/management && npx eslint --fix %:p && cd -<cr>",
            desc = "Lint Fix File - Management",
          },
          { "<leader>Cp", "<cmd>2TermExec cmd='just build-protos'<cr>", desc = "Build Protos" },
          { "<leader>Cr", "<cmd>2TermExec cmd='just reset-db'<cr>", desc = "Reset DB" },
          { "<leader>D", "<cmd>delm! | delm A-Z0-9<CR>", desc = "Delete All Marks" },
          { "<leader>H", "<cmd>HelpVert<CR>", desc = "Get Help in a Vertical Split to the Left" },
          { "<leader>I", "<cmd>lua AddSpecifiedImport()<CR>", desc = "Import Word Under Cursor" },
          { "<leader>L", "<cmd>Lazy<CR>", desc = "Lazy" },
          { "<leader>M", "<cmd>Mason<CR>", desc = "Mason" },
          { "<leader>P", "i<C-R>0<esc>", desc = "Paste the last yank in place" },
          { "<leader>R", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename" },
          { "<leader>s", group = "Spectre - find and replace" },
          { "<leader>ss", "<cmd>lua require('spectre').open_visual()<CR>", desc = "Open Spectre" },
          {
            "<leader>sw",
            "<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
            desc = "Search for word under cursor",
          },
          { "<leader>T", group = "Test" },
          { "<leader>TF", "<cmd>lua playwright.run_all_tests(20)<CR>", desc = "Run Playwright Test File 20 Times" },
          {
            "<leader>TN",
            "<cmd>lua playwright.run_nearest_test(20)<CR>",
            desc = "Run Nearest Playwright Test 20 Times",
          },
          { "<leader>Tc", "<cmd>lua playwright.close_test_terminal()<CR>", desc = "Close Test Terminal" },
          { "<leader>Tf", "<cmd>lua playwright.run_all_tests()<CR>", desc = "Run Playwright Test File" },
          { "<leader>Tl", "<cmd>lua playwright.run_last_test()<CR>", desc = "Run Last Playwright Test" },
          { "<leader>Tn", "<cmd>lua playwright.run_nearest_test()<CR>", desc = "Run Nearest Playwright Test" },
          { "<leader>Td", "<cmd>lua playwright.debug_nearest_test()<CR>", desc = "Debug Nearest Playwright Test" },
          { "<leader>Tv", "<cmd>lua playwright.open_test_video()<CR>", desc = "Open Test Video" },
          { "<leader>Tt", "<cmd>lua playwright.open_test_trace()<CR>", desc = "Open Test Trace" },
          { "<leader>a", "<cmd>CodeActionMenu<CR>", desc = "Code Actions" },
          { "<leader>b", group = "Bufferline" },
          { "<leader>bA", "<cmd>bufdo bd<CR>", desc = "Close all" },
          { "<leader>ba", "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", desc = "Close all but current" },
          { "<leader>bb", "<cmd>BufferLinePick<CR>", desc = "Pick" },
          { "<leader>bc", "<cmd>bd<CR>", desc = "Close buffer" },
          { "<leader>bg", "<cmd>lua DeleteUnchangedGitBuffers()<CR>", desc = "Delete Unchanged Buffers (Git)" },
          { "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", desc = "Close all to left" },
          { "<leader>bl", "<cmd>BufferLineCloseRight<CR>", desc = "Close all to right" },
          { "<leader>bn", "<cmd>tabnew<CR>", desc = "New Buffer" },
          { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
          { "<leader>bq", "<cmd>BufferLinePickClose<CR>", desc = "Pick to close" },
          { "<leader>cc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
          { "<leader>d", "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", desc = "Line Diagnostics" },
          { "<leader>e", "<cmd>lua require('oil').toggle_float()<CR>", desc = "Oil" },
          { "<leader>f", group = "Find with Telescope" },
          { "<leader>fc", "<cmd>lua search_changed_files()<cr>", desc = "Changed Files" },
          { "<leader>fC", "<cmd>lua live_grep_changed_files()<cr>", desc = "Grep Changed Files" },
          { "<leader>fB", "<cmd>Telescope bookmarks<cr>", desc = "Find Bookmark" },
          { "<leader>fF", "<cmd>Telescope file_browser<CR>", desc = "Browse Files" },
          { "<leader>fG", "<cmd>Telescope git_status<CR>", desc = "Git Status" },
          { "<leader>fH", "<cmd>Telescope harpoon marks<CR>", desc = "Harpoon Marks" },
          { "<leader>fM", "<cmd>Telescope man_pages<CR>", desc = "Man Pages" },
          { "<leader>fT", "<cmd>TodoTelescope<CR>", desc = "Search Todos" },
          { "<leader>fa", "<cmd>Telescope session-lens search_session<CR>", desc = "Search Sessions" },
          { "<leader>fb", "<cmd>lua checkout_branch_and_reload_session()<cr>", desc = "Find Branch" },
          { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Document Diagnostics" },
          { "<leader>fe", "<cmd>Easypick<CR>", desc = "Easypick" },
          {
            "<leader>ff",
            '<cmd> lua require"telescope.builtin".find_files({ hidden = true })<CR>',
            desc = "Find File",
          },
          { "<leader>fg", "<cmd>Telescope live_grep_args<CR>", desc = "Live Grep" },
          { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search Help" },
          { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Key Mappings" },
          { "<leader>fm", "<cmd>Telescope marks<CR>", desc = "Marks" },
          { "<leader>fn", "<cmd>TodoTelescope<cr>", desc = "Find Notes" },
          { "<leader>fo", "<cmd>Telescope buffers<cr>", desc = "Open Buffer" },
          { "<leader>fq", group = "Narrow Quickfix List" },
          { "<leader>fqf", "<cmd>lua Search_qflist('find_files')<CR>", desc = "Find Files" },
          { "<leader>fqI", "<cmd>lua Search_qflist('inverse_find_files')<CR>", desc = "Inverse Find Files" },
          { "<leader>fqg", "<cmd>lua Search_qflist('live_grep')<CR>", desc = "Live Grep" },
          { "<leader>fqi", "<cmd>lua Search_qflist('inverse_live_grep')<CR>", desc = "Inverse Live Grep" },
          { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Find References" },
          { "<leader>ft", "<cmd>Telescope builtin<cr>", desc = "Telescope builtin" },
          {
            "<leader>fv",
            "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>",
            desc = "Grep Visual Selection",
          },
          {
            "<leader>fw",
            "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()<CR>",
            desc = "Grep Word Under Cursor",
          },
          -- { "<leader>f", group = "Find with FzfLua" },
          -- { "<leader>fB", "<cmd>Telescope bookmarks<cr>", desc = "Find Bookmark" },
          -- { "<leader>fF", "<cmd>FzfLua files<CR>", desc = "Browse Files" },
          -- { "<leader>fG", "<cmd>Telescope git_status<CR>", desc = "Git Status" },
          -- { "<leader>fH", "<cmd>Telescope harpoon marks<CR>", desc = "Harpoon Marks" },
          -- { "<leader>fM", "<cmd>Telescope man_pages<CR>", desc = "Man Pages" },
          -- { "<leader>fT", "<cmd>TodoTelescope<CR>", desc = "Search Todos" },
          -- { "<leader>fa", "<cmd>Telescope session-lens search_session<CR>", desc = "Search Sessions" },
          -- { "<leader>fb", "<cmd>lua checkout_branch_and_reload_session()<cr>", desc = "Find Branch" },
          -- { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Document Diagnostics" },
          -- { "<leader>fe", "<cmd>Easypick<CR>", desc = "Easypick" },
          -- {
          --   "<leader>ff",
          --   "<cmd>FzfLua files<CR>",
          --   desc = "Find File",
          -- },
          -- { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep" },
          -- -- { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search Help" },
          -- -- { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Key Mappings" },
          -- -- { "<leader>fm", "<cmd>Telescope marks<CR>", desc = "Marks" },
          -- -- { "<leader>fn", "<cmd>TodoTelescope<cr>", desc = "Find Notes" },
          -- -- { "<leader>fo", "<cmd>Telescope buffers<cr>", desc = "Open Buffer" },
          -- { "<leader>fq", group = "Live Grep Quickfix List" },
          -- { "<leader>fqf", "<cmd>FzfLua lgrep_quickfix rg_glob=true<CR>", desc = "Find Files" },
          -- { "<leader>fqg", "<cmd>FzfLua lgrep_quickfix<CR>", desc = "Live Grep" },
          -- { "<leader>fqi", "<cmd>FzfLua lgrep_quickfix -rg_opts='v'<CR>", desc = "Inverse Live Grep" },
          -- { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Find References" },
          -- { "<leader>ft", "<cmd>Telescope builtin<cr>", desc = "Telescope builtin" },
          -- {
          --   "<leader>fv",
          --   "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>",
          --   desc = "Grep Visual Selection",
          -- },
          -- {
          --   "<leader>fw",
          --   "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()<CR>",
          --   desc = "Grep Word Under Cursor",
          -- },
          { "<leader>g", group = "Git" },
          { "<leader>gB", "<cmd>lua checkout_new_branch()<cr>", desc = "New Branch" },
          {
            "<leader>ga",
            "<cmd>Git stage . | Git commit -m 'wip' | Git push<CR>",
            desc = "Stage, Commit WIP, and Push",
          },
          { "<leader>gb", "<cmd>Git blame<CR>", desc = "Blame" },
          { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
          { "<leader>gd", "<cmd>DiffviewOpen origin/master<CR>", desc = "Diff with origin/master" },
          { "<leader>gf", "<cmd>lua diffview_file_history()<CR>", desc = "File History" },
          { "<leader>gg", "<cmd>0Git<CR>", desc = "0Git" },
          { "<leader>go", "<cmd>GBrowse master:%<CR>", desc = "Open in GitHub" },
          { "<leader>gp", "<cmd>Git push<CR>", desc = "Push" },
          { "<leader>gq", "<cmd>lua populate_quickfix_with_changed_files()<CR>", desc = "Populate Quickfix List" },
          { "<leader>gs", "<cmd>Git stage .<CR>", desc = "Stage All" },
          { "<leader>h", group = "Hunk" },
          { "<leader>hd", "<cmd>SignifyHunkDiff<CR>", desc = "Diff" },
          { "<leader>hu", "<cmd>SignifyHunkUndo<CR>", desc = "Undo" },
          { "<leader>i", group = "Trouble Issues" },
          { "<leader>iD", "<cmd>Trouble document_diagnostics<CR>", desc = "Buffer Diagnostics" },
          { "<leader>iT", "<cmd>TodoTrouble<CR>", desc = "Todos" },
          { "<leader>id", "<cmd>Trouble lsp_definitions<CR>", desc = "Definitions" },
          { "<leader>iq", "<cmd>Trouble quickfix<CR>", desc = "Quickfix" },
          { "<leader>ir", "<cmd>Trouble lsp_references<CR>", desc = "References" },
          { "<leader>it", "<cmd>TroubleToggle<CR>", desc = "Toggle" },
          { "<leader>iw", "<cmd>Trouble workspace_diagnostics<CR>", desc = "Workspace Diagnostics" },
          { "<leader>j", group = "Jump Navigate" },
          { "<leader>jC", "<cmd>/computed: <CR>", desc = "computed: " },
          { "<leader>jD", "<cmd>/defineComponent(<CR>", desc = "defineComponent(" },
          { "<leader>ja", "<cmd>/apollo: <CR>", desc = "apollo: " },
          { "<leader>jc", "<cmd>/<style<CR>", desc = "<style" },
          { "<leader>jd", "<cmd>/data(): <CR>", desc = "data(): " },
          { "<leader>ji", "<cmd>/interface [A-Za-z]*Data <CR>", desc = "Data Interface" },
          { "<leader>jm", "<cmd>/methods: <CR>", desc = "methods: " },
          { "<leader>js", "<cmd>/<script<CR>", desc = "<script" },
          { "<leader>jt", "<cmd>/<template<CR>", desc = "<template" },
          { "<leader>ju", "<cmd>/update(<CR>", desc = "update(" },
          { "<leader>jw", "<cmd>/watch: <CR>", desc = "watch: " },
          { "<leader>k", "<cmd>WhichKey<CR>", desc = "WhichKey" },
          { "<leader>l", group = "LSP" },
          { "<leader>lR", "<cmd> lua vim.lsp.buf.references()<CR>", desc = "List references" },
          { "<leader>lc", "<cmd>CodeActionMenu<CR>", desc = "Code actions" },
          { "<leader>ld", "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", desc = "Line Diagnostics" },
          { "<leader>lf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", desc = "Format File" },
          { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename" },
          { "<leader>m", group = "Harpoon Marks" },
          { "<leader>ma", "<cmd>lua require('harpoon.mark').add_file()<CR>", desc = "Add File Mark" },
          { "<leader>mm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = "Toggle Quick Menu" },
          { "<leader>mn", "<cmd>lua require('harpoon.ui').nav_next()<CR>", desc = "Navigate to Next Mark" },
          { "<leader>mp", "<cmd>lua require('harpoon.ui').nav_prev()<CR>", desc = "Navigate to Previous Mark" },
          { "<leader>o", group = "Octo" },
          { "<leader>oA", group = "Add Reviewers" },
          { "<leader>oAj", "<cmd>Octo reviewer add JordanMajd<cr>", desc = "Jordan Majd" },
          { "<leader>oAm", "<cmd>Octo reviewer add Matt-Sredojevic<cr>", desc = "Matt Sredojevic" },
          { "<leader>oAs", "<cmd>Octo reviewer add stearnsc<cr>", desc = "Colin Stearns" },
          { "<leader>oAt", "<cmd>Octo reviewer add ctil<cr>", desc = "Colin Tilleman" },
          { "<leader>oO", "<cmd>Octo pr create<cr>", desc = "Open PR" },
          { "<leader>oR", "<cmd>e! | Octo pr reload<cr>", desc = "Reload Buffer and PR" },
          { "<leader>oS", "<cmd>e! | Octo review submit<cr>", desc = "Submit Review" },
          { "<leader>oT", "<cmd>e! | Octo tag add<cr>", desc = "Add Tag" },
          { "<leader>oa", "<cmd>Octo comment add<cr>", desc = "Add Comment" },
          { "<leader>oc", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
          { "<leader>od", "<cmd>Octo comment delete<cr>", desc = "Delete Comment" },
          { "<leader>oh", "<cmd>Octo pr checks<cr>", desc = "Health Checks" },
          { "<leader>om", "<cmd>Octo pr merge squash<cr>", desc = "Squash Merge PR" },
          { "<leader>oo", "<cmd>Octo search is:pr is:open author:l-bowman<cr>", desc = "Show All My Open PRs" },
          { "<leader>op", "<cmd>Octo search is:pr author:l-bowman<cr>", desc = "Show All My PRs" },
          { "<leader>or", "<cmd>Octo thread resolve<cr>", desc = "Resolve Thread" },
          { "<leader>os", "<cmd>e! | Octo review start<cr>", desc = "Start Review" },
          {
            "<leader>ot",
            "<cmd>Octo pr list wyyerd/monorepo states=OPEN labels=team\\ orion<cr>",
            desc = "Show Orion Team PRs",
          },
          { "<leader>p", group = "Paste Special" },
          { "<leader>pB", "<cmd>lua paste_figma_color_variable('background')<cr>", desc = "Background Color" },
          { "<leader>pC", "<cmd>lua paste_figma_color_variable('color')<cr>", desc = "Color" },
          { "<leader>pb", "<cmd>lua paste_figma_color_variable('bg-color')<cr>", desc = "bg-color" },
          { "<leader>pc", "<cmd>lua paste_figma_color_variable('text-color')<cr>", desc = "text-color" },
          { "<leader>pi", "<cmd>lua SmartImportPasteAndLint()<CR>", desc = "Smart Import Paste" },
          { "<leader>q", group = "Quickfix" },
          {
            "<leader>qa",
            "<cmd>lua add_current_line_to_named_quickfix('my_list')<CR>",
            desc = "Add Line to Quickfix List",
          },
          { "<leader>qo", "<cmd>lua open_named_quickfix('my_list')<CR>", desc = "Open Quickfix List" },
          { "<leader>ql", "<cmd>lua list_all_quickfix_lists()<CR>", desc = "List Quickfix Lists" },
          { "<leader>qs", "<cmd>lua save_quickfix_lists()<CR>", desc = "Save Quickfix Lists" },
          { "<leader>qL", "<cmd>lua load_quickfix_lists()<CR>", desc = "Load Quickfix Lists" },
          { "<leader>qc", "<cmd>lua clear_saved_quickfix_lists()<CR>", desc = "Clear Quickfix Lists" },
          { "<leader>qr", "<cmd>lua remove_current_qf_entry()<CR>", desc = "Remove Current Quickfix Entry" },
          { "<leader>r", "<cmd>e! | LspRestart | Copilot enable<CR>", desc = "Refresh LSP and Buffer" },
          -- { "<leader>r", "<cmd>e! | LspRestart<CR>", desc = "Refresh LSP and Buffer" },
          -- { "<leader>s", group = "Starpower" },
          -- { "<leader>ss", "<cmd>StarpowerStarCurrentFile<CR>", desc = "Star" },
          -- { "<leader>su", "<cmd>StarpowerUnstarCurrentFile<CR>", desc = "Unstar" },
          -- { "<leader>sa", "<cmd>StarpowerStarAll<CR>", desc = "Star all files" },
          -- { "<leader>sd", "<cmd>StarpowerClearAll<CR>", desc = "Clear all starred files" },
          -- { "<leader>so", "<cmd>StarpowerOpenStarred<CR>", desc = "Open all starred files" },
          -- { "<leader>sc", "<cmd>StarpowerCloseNonStarred<CR>", desc = "Close non-starred files" },
          -- { "<leader>sC", "<cmd>StarpowerCloseStarred<CR>", desc = "Close starred files" },
          -- { "<leader>sq", "<cmd>StarpowerOpenStarredInQuickfix<CR>", desc = "Open starred in Quickfix" },
          { "<leader>S", "<cmd>lua vim.o.spell = not vim.o.spell<cr>", desc = "Toggle spell check" },
          { "<leader>t", "<cmd>lua toggle_term()<CR>", desc = "Toggle Tmux Terminal" },
          { "<leader>u", "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", desc = "Undotree" },
          { "<leader>v", group = "Vue Shortcuts" },
          { "<leader>vr", "<cmd>lua InsertVueRouterCode()<CR>", desc = "Insert Vue Router Code" },
          {
            "<leader>w",
            "<cmd>lua sessionSaveAndFormatWrite()<cr>",
            desc = "Save Session and Format and Write Buffer",
          },
          { "<leader>x", group = "AI" },
          { "<leader>xc", "<cmd>AvanteClear<cr>", desc = "Avante Clear" },
          { "<leader>xs", group = "Chat Snippets" },
          {
            "<leader>xsd",
            "<cmd>lua _G.start_chatgpt_session_with_prompt(_G.ai_snippets.dieselSnippet)<CR>",
            desc = "Diesel Snippet",
          },
          { "<leader>y", group = "Yank" },
          { "<leader>ya", '<cmd>let @+ = expand("%:p")<cr>', desc = "Absolute Path" },
          { "<leader>yb", '<cmd>normal gg"+yG<cr>', desc = "Buffer" },
          { "<leader>ye", "<cmd>lua ImportWordUnderCursor()<CR>", desc = "Export Under Cursor as Import" },
          { "<leader>yl", '<cmd>normal "+yy<cr>', desc = "Line" },
          { "<leader>yn", '<cmd>let @+ = expand("%:t")<cr>', desc = "Filename" },
          { "<leader>yr", '<cmd>let @+ = expand("%")<cr>', desc = "Relative Path (src)" },
          { "<leader>yv", "<cmd>lua GetVueStyleImport()<cr>", desc = "Vue-Style Import" },
          { "<leader>z", group = "Timewarp" },
          { "<leader>ze", "<cmd>TimewarpLastEdit<cr>", desc = "Warp to Last Edit" },
          { "<leader>zi", "<cmd>TimewarpReturn<cr>", desc = "Return to Initial Position" },
          { "<leader>zy", "<cmd>TimewarpLastYank<cr>", desc = "Warp to Last Yank" },
        },
      })

      wk.add({
        {
          { "g", group = "Go to" },
          { "gD", desc = "Declaration" },
          { "gd", desc = "Definition" },
          -- { "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>", desc = "Definition" },
          { "gi", desc = "Implementation" },
          { "gr", desc = "References" },
        },
      })

      wk.add({

        {
          {
            mode = { "v" },
            { "<leader>", group = "Visual Mode" },
            { "<leader>E", "<cmd>ChatGPTEditWithInstructions<CR>", desc = "GPT Edit with Instructions" },
            { "<leader>e", "<cmd>ChatGPTRun explain_code<CR>", desc = "GPT Explain Code" },
            {
              "<leader>f",
              "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>",
              desc = "Grep Visual Selection",
            },
            { "<leader>p", '"_dP', desc = "Paste over selection without yanking" },
            { "<leader>s", "<cmd>ChatGPTRun summarize<CR>", desc = "GPT Summarize" },
            { "<leader>t", group = "Translate" },
            { "<leader>te", "<cmd>ChatGPTRun translate<CR>", desc = "To English" },
            { "<leader>tg", "<cmd>ChatGPTRun translate German<CR>", desc = "To German" },
            { "<leader>ts", "<cmd>ChatGPTRun translate Spanish<CR>", desc = "To Spanish" },
          },
        },
      })
    end,
  },
}
