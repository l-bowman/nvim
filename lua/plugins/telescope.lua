return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "rmagatti/session-lens",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    lazy = false,
    opts = {
      defaults = {
        layout_config = {
          vertical = { width = 0.5 },
          -- other layout configuration here
        },
        file_ignore_patterns = { ".git/", "node_modules/", "env/" }, -- ignore git
        winblend = 0,
      },
      pickers = {
        find_files = {
          theme = "ivy",
        },
        live_grep = {
          theme = "ivy",
        },
      },
    },
    keys = {
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files({ hidden = true })
        end,
        desc = "Find Files (root dir)",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")

      telescope.setup(opts)

      -- telescope.load_extension("session-lens")
      telescope.load_extension("file_browser")

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
      _G.Live_grep_qflist = search_qflist

      telescope.load_extension("session-lens")
    end,
  },
}
