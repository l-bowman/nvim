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
        f = {
          -- mostly Telescope bindings
          name = "Find with Telescope",
          f = { [[<cmd> lua require"telescope.builtin".find_files({ hidden = true })<CR>]], "Find File" },
          b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
          n = { "<cmd>TodoTelescope<cr>", "Find Notes" },
          t = { "<cmd>Telescope builtin<cr>", "Telescope builtin" },
          r = { "<cmd>Telescope lsp_references<cr>", "Find References" },
          d = { "<cmd>Telescope diagnostics<cr>", "Document Diagnostics" },
          m = { "<cmd>Telescope marks<CR>", "Marks" },
          k = { "<cmd>Telescope keymaps<CR>", "Key mappings" },
          M = { "<cmd>Telescope man_pages<CR>", "Man pages" },
          a = { "<cmd>Telescope session-lens search_session<CR>", "Search Sessions" },
          h = { "<cmd>Telescope help_tags<CR>", "Search help" },
          T = { "<cmd>TodoTelescope<CR>", "Search Todos" },
          g = { "<cmd>lua require('telescope.builtin').live_grep()<CR>", "Live Grep" },
          q = {
            name = "Live Grep Quickfix List",
            g = { "<cmd>lua Search_qflist('live_grep')<CR>", "Live Grep" },
            i = { "<cmd>lua Search_qflist('inverse_live_grep')<CR>", "Inverse Live Grep" },
            f = { "<cmd>lua Search_qflist('find_files')<CR>", "Find Files" },
          },
          e = { "<cmd>Telescope file_browser<CR>", "Browse Files" },
        },
        -- h = {
        --   name = "Git Gutter",
        --   p = "Preview Hunk",
        --   s = "Stage Hunk",
        --   u = "Undo Changes",
        -- },
        e = { "<cmd>NvimTreeToggle<CR>", "File Tree" },
        u = { "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", "Undotree" },
        L = { "<cmd>Lazy<CR>", "Lazy" },
        -- trouble bindings
        t = {
          name = "Trouble",
          t = { "<cmd>TroubleToggle<CR>", "Toggle" },
          r = { "<cmd>Trouble lsp_references<CR>", "References" },
          d = { "<cmd>Trouble lsp_definitions<CR>", "Definitions" },
          q = { "<cmd>Trouble quickfix<CR>", "Quickfix" },
          T = { "<cmd>TodoTrouble<CR>", "Todos" },
          w = { "<cmd>Trouble workspace_diagnostics<CR>", "Workspace Diagnostics" },
          D = { "<cmd>Trouble document_diagnostics<CR>", "Document Diagnostics" },
        },
        T = { "<cmd>TodoTelescope<CR>", "List Todos" },
        c = { "<cmd>CodeActionMenu<CR>", "Code Actions" },
        d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
        s = { "<cmd>lua vim.o.spell = not vim.o.spell<cr>", "Toggle spell check" },
        r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        w = { "<cmd>write<CR>", "Quick Save" },
        W = { "<cmd>WhichKey<CR>", "WhichKey" },
        -- Bufferline
        b = {
          name = "Bufferline",
          A = { "<cmd>%bd<CR>", "Close all" },
          b = { "<cmd>BufferLinePick<CR>", "Pick" },
          q = { "<cmd>BufferLinePickClose<CR>", "Pick to close" },
          l = { "<cmd>BufferLineCloseRight<CR>", "Close all to right" },
          h = { "<cmd>BufferLineCloseLeft<CR>", "Close all to left" },
          a = { "<cmd>BufferLineCloseLeft<CR><cmd>BufferLineCloseRight<CR>", "Close all but current" },
          p = { "<cmd>BufferLineTogglePin<CR>", "Toggle pin" },
        },
        S = {
          name = "Spectre - find and replace",
          s = { "<cmd>lua require('spectre').open_visual()<CR>", "Open Spectre" },
          w = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search for word under cursor" },
        },
        l = {
          name = "LSP",
          f = { "<cmd>lua vim.lsp.buf.format({async = true})<CR>", "Format File" },
          d = { "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", "Line Diagnostics" },
          r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
          R = { "<cmd> lua vim.lsp.buf.references()<CR>", "List references" },
          c = { "<cmd>CodeActionMenu<CR>", "Code actions" },
        },
        a = {
          name = "Auto Sessions",
          S = { "<cmd>SaveSession<cr>", "Save session" },
          s = { "<cmd>SearchSession<cr>", "Search sessions" },
          d = { "<cmd>DeleteSession<cr>", "Delete session" },
          r = { "<cmd>RestoreSession<cr>", "Restore session" },
        },
        y = {
          name = "Yank",
          n = { '<cmd>let @+ = expand("%:t")<cr>', "Filename" },
          r = { '<cmd>let @+ = expand("%")<cr>', "Relative Path" },
          a = { '<cmd>let @+ = expand("%:p")<cr>', "Absolute Path" },
        },
      }, {
        prefix = "<leader>",
      })

      wk.register({
        name = "Go to",
        d = "Definition",
        D = "Declaration",
        r = "References",
      }, { prefix = "g" })
    end,
  },
}
