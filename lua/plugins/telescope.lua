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

      -- live_grep a quickfix list!!!
      local builtin = require("telescope.builtin")
      Live_grep_qflist = function()
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

        builtin.live_grep({ search_dirs = filetable })
      end

      -- TODO: consolidate these two functions.
      Inverse_live_grep_qflist = function()
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

        builtin.live_grep({ search_dirs = filetable, additional_args = { "--files-without-match" } })
      end

      telescope.load_extension("session-lens")
    end,
  },
}
