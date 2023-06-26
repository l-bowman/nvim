local actions = require("telescope.actions")
local action_state = require("telescope.actions.state") -- additional require
local builtin = require("telescope.builtin")

function _G.checkout_branch_and_reload_session()
  builtin.git_branches({
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = action_state.get_selected_entry() -- correct function call
        actions.close(prompt_bufnr)

        -- Save session
        vim.cmd("SessionSave")

        -- Checkout the selected branch
        local command = string.format("git checkout %s", selection.value)
        vim.fn.system(command)

        -- Close all buffers
        vim.cmd("bufdo bd")

        -- Restore session
        vim.cmd("SessionRestore")
      end)
      return true
    end,
  })
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "dhruvmanila/browser-bookmarks.nvim",
    },
    lazy = false,
    opts = {

      extensions = {
        bookmarks = {
          selected_browser = "chrome",
        },
        live_grep_args = {
          auto_quoting = true, -- enable/disable auto-quoting
          mappings = {
            i = {
              -- TODO: Below mappings don't seem to work.
              ["<C-i>"] = function()
                return require("telescope-live-grep-args.actions").quote_prompt()
              end,
              ["<C-t>"] = function()
                return require("telescope-live-grep-args.actions").quote_prompt({ postfix = " -t " })
              end,
              -- ['<C-g>'] = lga_actions.quote_prompt { postfix = ' services/graph' },
              -- ['<C-i>'] = lga_actions.quote_prompt { postfix = ' -i ' },
            },
          },
        },
      },
      defaults = {
        layout_strategy = "vertical",
        file_ignore_patterns = { ".git/", "node_modules/", "env/" }, -- ignore git
        winblend = 0,
        preview_cutoff = 10000, -- set preview_cutoff to prevent cutting off the results list
        wrap_results = true,
      },
      pickers = {
        find_files = {
          -- theme = "dropdown",
        },
        live_grep = {
          -- theme = "dropdown",
        },
      },
    },
    keys = {
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
        end,
        desc = "Find Files (root dir)",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("file_browser")
      telescope.load_extension("live_grep_args")
      telescope.load_extension("harpoon")

      local builtin = require("telescope.builtin")

      local search_qflist = function(mode)
        local qflist = vim.fn.getqflist()
        local filetable = {}
        local hashlist = {}

        for _, value in pairs(qflist) do
          local name = vim.api.nvim_buf_get_name(value.bufnr)

          if not hashlist[name] then
            hashlist[name] = true
            table.insert(filetable, name)
          end
        end

        local args = { search_dirs = filetable }

        if mode == "live_grep" then
          builtin.live_grep(args)
        elseif mode == "inverse_live_grep" then
          args.additional_args = { "--files-without-match" }
          builtin.live_grep(args)
        elseif mode == "find_files" then
          builtin.find_files(args)
        -- elseif mode == "inverse_find_files" then
        --   args.additional_args = { "--files-without-match" }
        --   builtin.find_files(args)
        else
          print("Invalid mode specified")
        end
      end

      -- assign function to global variable
      _G.Search_qflist = search_qflist

      telescope.load_extension("bookmarks")
    end,
  },
}
