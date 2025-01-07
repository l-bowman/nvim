local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

function _G.checkout_branch_and_reload_session()
  builtin.git_branches({
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Save session
        vim.cmd("SessionSave")

        -- Close all buffers
        vim.cmd("bufdo bd")

        -- Checkout the selected branch
        local command = string.format("git checkout %s", selection.value)
        vim.fn.system(command)

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
    },
    lazy = false,
    keys = {
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
        end,
        desc = "Find Files (root dir)",
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
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
        extensions = {
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            mappings = {
              i = {
                ["<Tab>"] = function()
                  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
                end, -- prevent tab key from auto-quoting, gawd that was annoying!
                ["<C-b>"] = require("telescope-live-grep-args.actions").quote_prompt({
                  postfix = " --iglob 'services/**/*.{rs,rpc}' --iglob '!libraries/**/*'",
                }),
                ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                ["<C-m>"] = require("telescope-live-grep-args.actions").quote_prompt({
                  postfix = " --iglob 'portals/management/**/*.{vue,ts,js}' --iglob '!portals/management/src/graph/**/*'",
                }),
                ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
              },
            },
          },
        },
      })
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
        elseif mode == "inverse_find_files" then
          local pattern = vim.fn.input("Exclude pattern: ")
          if pattern == "" then
            print("No pattern provided, showing all files.")
            builtin.find_files({ search_dirs = filetable })
            return
          end

          -- Convert the pattern to a Lua pattern
          local lua_pattern = pattern:gsub("%.", "%%."):gsub("%*", ".*")

          local filtered_files = {}
          for _, file in ipairs(filetable) do
            if not file:match(lua_pattern) then
              table.insert(filtered_files, file)
            end
          end

          if #filtered_files == 0 then
            print("No files found after applying the exclusion pattern.")
          else
            builtin.find_files({ search_dirs = filtered_files })
          end
        else
          print("Invalid mode specified")
        end
      end

      _G.Search_qflist = search_qflist
    end,
  },
}
