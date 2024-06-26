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
        window = {
          border = "single", -- none, single, double, shadow
          position = "bottom", -- bottom, top
          margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
          padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
          -- winblend = 0,
        },
        triggers_blacklist = {
          -- list of mode / prefixes that should never be hooked by WhichKey
          -- this is mostly relevant for key maps that start with a native binding
          -- most people should not need to change this
          i = { "j", "k" },
          v = { "j", "k" },
        },
      })
      wk.register({
        A = {
          name = "Auto Sessions",
          d = { "<cmd>SessionDelete<cr>", "Delete session" },
          r = { "<cmd>%bd!<CR><cmd>SessionRestore<cr>", "Restore session" },
          S = { "<cmd>SessionSave<cr>", "Save session" },
          s = { "<cmd>SessionSearch<cr>", "Search sessions" },
        },
        a = { "<cmd>CodeActionMenu<CR>", "Code Actions" },
        b = {
          name = "Bufferline",
          A = { "<cmd>bufdo bd<CR>", "Close all" },
          a = { "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", "Close all but current" },
          b = { "<cmd>BufferLinePick<CR>", "Pick" },
          c = { "<cmd>bd<CR>", "Close buffer" },
          g = { "<cmd>lua DeleteUnchangedGitBuffers()<CR>", "Delete Unchanged Buffers (Git)" },
          h = { "<cmd>BufferLineCloseLeft<CR>", "Close all to left" },
          l = { "<cmd>BufferLineCloseRight<CR>", "Close all to right" },
          n = { "<cmd>tabnew<CR>", "New Buffer" },
          p = { "<cmd>BufferLineTogglePin<CR>", "Toggle pin" },
          q = { "<cmd>BufferLinePickClose<CR>", "Pick to close" },
        },
        C = {
          name = "Console Commands",
          a = { "<cmd>2TermExec cmd='just build-apollo-full'<cr>", "Build Apollo Full" },
          C = { "<cmd>bufdo bd | :cd ~/.config/nvim<cr>", "Open NVIM Config" },
          c = { "<cmd>!cd portals/customer && npx eslint --fix %:p && cd -<cr>", "Lint Fix File - Customer" },
          D = { "<cmd>!rm -f ~/.local/share/nvim/sessions/*<cr>", "Remove All Sessions" },
          g = { "<cmd>2TermExec cmd='just clean-git-branches'<cr>", "Clean Git Branches" },
          m = { "<cmd>!cd portals/management && npx eslint --fix %:p && cd -<cr>", "Lint Fix File - Management" },
          p = { "<cmd>2TermExec cmd='just build-protos'<cr>", "Build Protos" },
          r = { "<cmd>2TermExec cmd='just reset-db'<cr>", "Reset DB" },
        },
        c = {
          c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
        },
        d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
        D = { "<cmd>delm! | delm A-Z0-9<CR>", "Delete All Marks" },
        e = { "<cmd>NvimTreeToggle<CR>", "File Tree" },
        f = {
          name = "Find with Telescope",
          a = { "<cmd>Telescope session-lens search_session<CR>", "Search Sessions" },
          B = { "<cmd>Telescope bookmarks<cr>", "Find Bookmark" },
          b = { "<cmd>lua checkout_branch_and_reload_session()<cr>", "Find Branch" },
          d = { "<cmd>Telescope diagnostics<cr>", "Document Diagnostics" },
          e = { "<cmd>Easypick<CR>", "Easypick" },
          F = { "<cmd>Telescope file_browser<CR>", "Browse Files" },
          f = { [[<cmd> lua require"telescope.builtin".find_files({ hidden = true })<CR>]], "Find File" },
          G = { "<cmd>Telescope git_status<CR>", "Git Status" },
          g = { "<cmd>Telescope live_grep_args<CR>", "Live Grep" },
          H = { "<cmd>Telescope harpoon marks<CR>", "Harpoon Marks" },
          h = { "<cmd>Telescope help_tags<CR>", "Search Help" },
          k = { "<cmd>Telescope keymaps<CR>", "Key Mappings" },
          M = { "<cmd>Telescope man_pages<CR>", "Man Pages" },
          m = { "<cmd>Telescope marks<CR>", "Marks" },
          n = { "<cmd>TodoTelescope<cr>", "Find Notes" },
          o = { "<cmd>Telescope buffers<cr>", "Open Buffer" },
          q = {
            name = "Live Grep Quickfix List",
            f = { "<cmd>lua Search_qflist('find_files')<CR>", "Find Files" },
            g = { "<cmd>lua Search_qflist('live_grep')<CR>", "Live Grep" },
            i = { "<cmd>lua Search_qflist('inverse_live_grep')<CR>", "Inverse Live Grep" },
          },
          r = { "<cmd>Telescope lsp_references<cr>", "Find References" },
          T = { "<cmd>TodoTelescope<CR>", "Search Todos" },
          t = { "<cmd>Telescope builtin<cr>", "Telescope builtin" },
          v = {
            "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>",
            "Grep Visual Selection",
          },
          w = {
            "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()<CR>",
            "Grep Word Under Cursor",
          },
        },
        g = {
          name = "Git",
          a = { "<cmd>Git stage . | Git commit -m 'wip' | Git push<CR>", "Stage, Commit WIP, and Push" },
          B = { "<cmd>lua checkout_new_branch()<cr>", "New Branch" },
          b = { "<cmd>Git blame<CR>", "Blame" },
          c = { "<cmd>DiffviewClose<CR>", "Close Diffview" },
          d = { "<cmd>DiffviewOpen origin/master<CR>", "Diff with origin/master" },
          f = { "<cmd>lua diffview_file_history()<CR>", "File History" },
          g = { "<cmd>0Git<CR>", "0Git" },
          o = { "<cmd>GBrowse master:%<CR>", "Open in GitHub" },
          p = { "<cmd>Git push<CR>", "Push" },
          s = { "<cmd>Git stage .<CR>", "Stage All" },
        },
        H = {
          "<cmd>HelpVert<CR>",
          "Get Help in a Vertical Split to the Left",
        },
        h = {
          name = "Hunk",
          d = { "<cmd>SignifyHunkDiff<CR>", "Diff" },
          u = { "<cmd>SignifyHunkUndo<CR>", "Undo" },
        },
        I = { "<cmd>lua AddSpecifiedImport()<CR>", "Import Word Under Cursor" },
        i = {
          name = "Trouble Issues",
          d = { "<cmd>Trouble lsp_definitions<CR>", "Definitions" },
          D = { "<cmd>Trouble document_diagnostics<CR>", "Buffer Diagnostics" },
          q = { "<cmd>Trouble quickfix<CR>", "Quickfix" },
          r = { "<cmd>Trouble lsp_references<CR>", "References" },
          t = { "<cmd>TroubleToggle<CR>", "Toggle" },
          T = { "<cmd>TodoTrouble<CR>", "Todos" },
          w = { "<cmd>Trouble workspace_diagnostics<CR>", "Workspace Diagnostics" },
        },
        j = {
          name = "Jump Navigate",
          a = { "<cmd>/apollo: <CR>", "apollo: " },
          C = { "<cmd>/computed: <CR>", "computed: " },
          c = { "<cmd>/<style<CR>", "<style" },
          D = { "<cmd>/defineComponent(<CR>", "defineComponent(" },
          d = { "<cmd>/data(): <CR>", "data(): " },
          i = { "<cmd>/interface [A-Za-z]*Data <CR>", "Data Interface" },
          m = { "<cmd>/methods: <CR>", "methods: " },
          s = { "<cmd>/<script<CR>", "<script" },
          t = { "<cmd>/<template<CR>", "<template" },
          u = { "<cmd>/update(<CR>", "update(" },
          w = { "<cmd>/watch: <CR>", "watch: " },
        },
        k = { "<cmd>WhichKey<CR>", "WhichKey" },
        L = { "<cmd>Lazy<CR>", "Lazy" },
        l = {
          name = "LSP",
          c = { "<cmd>CodeActionMenu<CR>", "Code actions" },
          d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
          f = { "<cmd>lua vim.lsp.buf.format({async = true})<CR>", "Format File" },
          r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
          R = { "<cmd> lua vim.lsp.buf.references()<CR>", "List references" },
        },
        M = { "<cmd>Mason<CR>", "Mason" },
        m = {
          name = "Harpoon Marks",
          a = { "<cmd>lua require('harpoon.mark').add_file()<CR>", "Add File Mark" },
          m = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", "Toggle Quick Menu" },
          n = { "<cmd>lua require('harpoon.ui').nav_next()<CR>", "Navigate to Next Mark" },
          p = { "<cmd>lua require('harpoon.ui').nav_prev()<CR>", "Navigate to Previous Mark" },
        },
        o = {
          name = "Octo",
          A = {
            name = "Add Reviewers",
            j = { "<cmd>Octo reviewer add JordanMajd<cr>", "Jordan Majd" },
            m = { "<cmd>Octo reviewer add Matt-Sredojevic<cr>", "Matt Sredojevic" },
            s = { "<cmd>Octo reviewer add stearnsc<cr>", "Colin Stearns" },
            t = { "<cmd>Octo reviewer add ctil<cr>", "Colin Tilleman" },
          },
          a = { "<cmd>Octo comment add<cr>", "Add Comment" },
          c = { "<cmd>Octo pr checkout<cr>", "Checkout PR" },
          d = { "<cmd>Octo comment delete<cr>", "Delete Comment" },
          h = { "<cmd>Octo pr checks<cr>", "Health Checks" },
          m = { "<cmd>Octo pr merge squash<cr>", "Squash Merge PR" },
          O = { "<cmd>Octo pr create<cr>", "Open PR" },
          o = { "<cmd>Octo search is:pr is:open author:l-bowman<cr>", "Show All My Open PRs" },
          p = { "<cmd>Octo search is:pr author:l-bowman<cr>", "Show All My PRs" },
          r = { "<cmd>Octo thread resolve<cr>", "Resolve Thread" },
          R = { "<cmd>e! | Octo pr reload<cr>", "Reload Buffer and PR" },
          s = { "<cmd>e! | Octo review start<cr>", "Start Review" },
          S = { "<cmd>e! | Octo review submit<cr>", "Submit Review" },
          T = { "<cmd>e! | Octo tag add<cr>", "Add Tag" },
          t = { "<cmd>Octo pr list wyyerd/monorepo states=OPEN labels=team\\ orion<cr>", "Show Orion Team PRs" },
        },
        P = { "i<C-R>0<esc>", "Paste the last yank in place" },
        p = {
          name = "Paste Special",
          B = {
            "<cmd>lua paste_figma_color_variable('background')<cr>",
            "Background Color",
          },
          b = {
            "<cmd>lua paste_figma_color_variable('bg-color')<cr>",
            "bg-color",
          },
          C = { "<cmd>lua paste_figma_color_variable('color')<cr>", "Color" },
          c = { "<cmd>lua paste_figma_color_variable('text-color')<cr>", "text-color" },
          i = { "<cmd>lua SmartImportPasteAndLint()<CR>", "Smart Import Paste" },
        },
        q = { qf_toggle, "Toggle Quickfix list" },
        R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        --TODO: enable when needed
        -- R = { "<Plug>RestNvim<CR>", "Run with Rest" },
        r = { "<cmd>e! | LspRestart<CR>", "Refresh LSP and Buffer" },
        S = {
          name = "Spectre - find and replace",
          s = { "<cmd>lua require('spectre').open_visual()<CR>", "Open Spectre" },
          w = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search for word under cursor" },
        },
        s = { "<cmd>lua vim.o.spell = not vim.o.spell<cr>", "Toggle spell check" },
        T = {
          name = "Test",
          c = { "<cmd>lua playwright.close_test_terminal()<CR>", "Close Test Terminal" },
          F = { "<cmd>lua playwright.run_all_tests(20)<CR>", "Run Playwright Test File 20 Times" },
          f = { "<cmd>lua playwright.run_all_tests()<CR>", "Run Playwright Test File" },
          l = { "<cmd>lua playwright.run_last_test()<CR>", "Run Last Playwright Test" },
          N = { "<cmd>lua playwright.run_nearest_test(20)<CR>", "Run Nearest Playwright Test 20 Times" },
          n = { "<cmd>lua playwright.run_nearest_test()<CR>", "Run Nearest Playwright Test" },
        },
        t = { "<cmd>lua toggle_term()<CR>", "Toggle Tmux Terminal" },
        u = { "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", "Undotree" },
        v = {
          name = "Vue Shortcuts",
          r = { "<cmd>lua InsertVueRouterCode()<CR>", "Insert Vue Router Code" },
        },
        w = { "<cmd>lua sessionSaveAndFormatWrite()<cr>", "Save Session and Format and Write Buffer" },
        y = {
          name = "Yank",
          a = { '<cmd>let @+ = expand("%:p")<cr>', "Absolute Path" },
          b = { '<cmd>normal gg"+yG<cr>', "Buffer" },
          e = { "<cmd>lua ImportWordUnderCursor()<CR>", "Export Under Cursor as Import" },
          l = { '<cmd>normal "+yy<cr>', "Line" },
          n = { '<cmd>let @+ = expand("%:t")<cr>', "Filename" },
          r = { '<cmd>let @+ = expand("%")<cr>', "Relative Path (src)" },
          v = { "<cmd>lua GetVueStyleImport()<cr>", "Vue-Style Import" },
        },
        z = {
          name = "Timewarp",
          e = { "<cmd>TimewarpLastEdit<cr>", "Warp to Last Edit" },
          i = { "<cmd>TimewarpReturn<cr>", "Return to Initial Position" },
          y = { "<cmd>TimewarpLastYank<cr>", "Warp to Last Yank" },
        },
      }, {
        prefix = "<leader>",
      })

      wk.register({
        name = "Go to",
        D = "Declaration",
        d = "Definition",
        i = "Implementation",
        r = "References",
      }, { prefix = "g" })

      wk.register({
        name = "Visual Mode",
        E = { "<cmd>ChatGPTEditWithInstructions<CR>", "GPT Edit with Instructions" },
        e = { "<cmd>ChatGPTRun explain_code<CR>", "GPT Explain Code" },
        f = {
          "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>",
          "Grep Visual Selection",
        },
        p = { '"_dP', "Paste over selection without yanking" },
        s = { "<cmd>ChatGPTRun summarize<CR>", "GPT Summarize" },
        t = {
          name = "Translate",
          e = { "<cmd>ChatGPTRun translate<CR>", "To English" },
          g = { "<cmd>ChatGPTRun translate German<CR>", "To German" },
          s = { "<cmd>ChatGPTRun translate Spanish<CR>", "To Spanish" },
        },
      }, { mode = "v", prefix = "<leader>" })
    end,
  },
}
