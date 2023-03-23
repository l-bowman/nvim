return {
  {
    "folke/which-key.nvim",
    opts = {
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
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- register key bindings with <leader> prefix
      wk.register({
        a = {
          name = "Auto Sessions",
          d = { "<cmd>DeleteSession<cr>", "Delete session" },
          r = { "<cmd>RestoreSession<cr>", "Restore session" },
          S = { "<cmd>SaveSession<cr>", "Save session" },
          s = { "<cmd>SearchSession<cr>", "Search sessions" },
        },
        b = {
          name = "Bufferline",
          A = { "<cmd>bd<CR>", "Close all" },
          a = { "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", "Close all but current" },
          b = { "<cmd>BufferLinePick<CR>", "Pick" },
          h = { "<cmd>BufferLineCloseLeft<CR>", "Close all to left" },
          l = { "<cmd>BufferLineCloseRight<CR>", "Close all to right" },
          p = { "<cmd>BufferLineTogglePin<CR>", "Toggle pin" },
          q = { "<cmd>BufferLinePickClose<CR>", "Pick to close" },
        },
        c = { "<cmd>CodeActionMenu<CR>", "Code Actions" },
        d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
        e = { "<cmd>NvimTreeToggle<CR>", "File Tree" },
        f = {
          name = "Find with Telescope",
          a = { "<cmd>Telescope session-lens search_session<CR>", "Search Sessions" },
          b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
          d = { "<cmd>Telescope diagnostics<cr>", "Document Diagnostics" },
          e = { "<cmd>Telescope file_browser<CR>", "Browse Files" },
          f = { [[<cmd> lua require"telescope.builtin".find_files({ hidden = true })<CR>]], "Find File" },
          g = { "<cmd>lua require('telescope.builtin').live_grep()<CR>", "Live Grep" },
          h = { "<cmd>Telescope help_tags<CR>", "Search help" },
          k = { "<cmd>Telescope keymaps<CR>", "Key mappings" },
          M = { "<cmd>Telescope man_pages<CR>", "Man pages" },
          m = { "<cmd>Telescope marks<CR>", "Marks" },
          n = { "<cmd>TodoTelescope<cr>", "Find Notes" },
          q = {
            name = "Live Grep Quickfix List",
            f = { "<cmd>lua Search_qflist('find_files')<CR>", "Find Files" },
            g = { "<cmd>lua Search_qflist('live_grep')<CR>", "Live Grep" },
            i = { "<cmd>lua Search_qflist('inverse_live_grep')<CR>", "Inverse Live Grep" },
          },
          r = { "<cmd>Telescope lsp_references<cr>", "Find References" },
          T = { "<cmd>TodoTelescope<CR>", "Search Todos" },
          t = { "<cmd>Telescope builtin<cr>", "Telescope builtin" },
        },
        h = {
          name = "Git",
          a = { "<cmd>Git stage . | Git commit -m 'wip' | Git push<CR>", "Stage, Commit WIP, and Push" },
          c = { "<cmd>Git commit -m 'wip'<CR>", "Commit WIP" },
          d = { "<cmd>Gdiffsplit<CR>", "Show Diff (index on right)" },
          g = { "<cmd>0Git<CR>", "0Git" },
          h = {
            "<cmd>Gllog origin/master -100 --decorate --first-parent --merges<CR>",
            "Last 100 Merge Commits (origin/master)",
          },
          l = { "<cmd>0Gllog<CR>", "Show File Revisions" },
          p = { "<cmd>Git push<CR>", "Push" },
          s = { "<cmd>Git stage .<CR>", "Stage All" },
          v = { "<cmd>Gvdiffsplit origin/master<CR>", "Diff with origin/master" },
        },
        L = { "<cmd>Lazy<CR>", "Lazy" },
        l = {
          name = "LSP",
          c = { "<cmd>CodeActionMenu<CR>", "Code actions" },
          d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
          f = { "<cmd>lua vim.lsp.buf.format({async = true})<CR>", "Format File" },
          r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
          R = { "<cmd> lua vim.lsp.buf.references()<CR>", "List references" },
        },
        o = {
          name = "Octo",
          a = { "<cmd>Octo comment add<cr>", "Add Comment" },
          c = { "<cmd>Octo pr checkout<cr>", "Checkout PR" },
          d = { "<cmd>Octo comment delete<cr>", "Delete Comment" },
          m = { "<cmd>Octo pr merge squash<cr>", "Squash Merge PR" },
          o = { "<cmd>Octo search is:pr is:open author:l-bowman<cr>", "Show All My Open PRs" },
          p = { "<cmd>Octo search is:pr author:l-bowman<cr>", "Show All My PRs" },
          t = { "<cmd>Octo pr list wyyerd/monorepo states=OPEN labels=team\\ orion<cr>", "Show Orion Team PRs" },
        },
        r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        S = {
          name = "Spectre - find and replace",
          s = { "<cmd>lua require('spectre').open_visual()<CR>", "Open Spectre" },
          w = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search for word under cursor" },
        },
        s = { "<cmd>lua vim.o.spell = not vim.o.spell<cr>", "Toggle spell check" },
        T = { "<cmd>TodoTelescope<CR>", "List Todos" },
        t = {
          name = "Trouble",
          d = { "<cmd>Trouble lsp_definitions<CR>", "Definitions" },
          D = { "<cmd>Trouble document_diagnostics<CR>", "Buffer Diagnostics" },
          q = { "<cmd>Trouble quickfix<CR>", "Quickfix" },
          r = { "<cmd>Trouble lsp_references<CR>", "References" },
          t = { "<cmd>TroubleToggle<CR>", "Toggle" },
          T = { "<cmd>TodoTrouble<CR>", "Todos" },
          w = { "<cmd>Trouble workspace_diagnostics<CR>", "Workspace Diagnostics" },
        },
        u = { "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", "Undotree" },
        W = { "<cmd>WhichKey<CR>", "WhichKey" },
        w = { "<cmd>Format | write<CR>", "Quick Save" },
        y = {
          name = "Yank",
          a = { '<cmd>let @+ = expand("%:p")<cr>', "Absolute Path" },
          n = { '<cmd>let @+ = expand("%:t")<cr>', "Filename" },
          r = {
            '<cmd>let @+ = expand("%")<cr>',
            "Relative Path (src)",
          },
          v = {
            "<cmd>let @\" = 'import  from \"' . \"@/\" . substitute(expand(\"%\"), '\\(.*src\\)/\\?', '', ''). '\"' . ';'<cr>",
            "Vue Style Import",
          },
        },
      }, {
        prefix = "<leader>",
      })

      wk.register({
        name = "Go to",
        D = "Declaration",
        d = "Definition",
        r = "References",
      }, { prefix = "g" })
    end,
  },
}
