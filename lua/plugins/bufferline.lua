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
        },
      },
    },
  },
}
