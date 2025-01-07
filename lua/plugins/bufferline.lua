return {
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "kyazdani42/nvim-web-devicons",
    },
    opts = {
      options = {
        offsets = {
          {
            filetype = "NvimTree",
            -- text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
        diagnostics = "nvim_lsp",
        max_name_length = 22,
        tab_size = 22,
        groups = {
          options = {
            toggle_hidden_on_enter = true, -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
            duplicates_across_groups = false, -- whether to consider duplicate paths in different groups as duplicates
          },
          -- items = {
          --   {
          --     name = "Starred",
          --     -- highlight = { underline = true, sp = "green" }, -- Optional
          --     priority = 1, -- determines where it will appear relative to other groups (Optional)
          --     icon = "⭐", -- Optional
          --     matcher = function(buf)
          --       local is_starred, result = pcall(require("starpower").is_file_starred, buf.path)
          --       return is_starred and result
          --     end,
          --   },
          --   {
          --     name = "References",
          --     -- highlight = { underline = true, sp = "orange" }, -- Optional
          --     priority = 2, -- determines where it will appear relative to other groups (Optional)
          --     icon = "📚", -- Optional
          --     matcher = function(buf)
          --       local is_starred, result = pcall(require("starpower").is_file_starred, buf.path, "r")
          --       return is_starred and result
          --     end,
          --   },
          --   {
          --     name = "Frontend",
          --     -- highlight = { underline = true, sp = "turquoise" }, -- Optional
          --     priority = 3, -- determines where it will appear relative to other groups (Optional)
          --     icon = "💁", -- Optional
          --     matcher = function(buf)
          --       local is_starred, result = pcall(require("starpower").is_file_starred, buf.path, "f")
          --       return is_starred and result
          --     end,
          --   },
          --   {
          --     name = "Backend",
          --     -- highlight = { underline = true, sp = "blue" }, -- Optional
          --     priority = 4, -- determines where it will appear relative to other groups (Optional)
          --     icon = "🗄", -- Optional
          --     matcher = function(buf)
          --       local is_starred, result = pcall(require("starpower").is_file_starred, buf.path, "b")
          --       return is_starred and result
          --     end,
          --   },
          -- },
        },
      },
    },
  },
}
