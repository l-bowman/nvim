return {
  -- NOTE: plugins here require little to no configuratin

  "tpope/vim-fugitive",
  "tpope/vim-surround",

  -- NOTE: disabled for now as not working with nvim window bindings
  -- "knubie/vim-kitty-navigator",
  "windwp/nvim-autopairs",
  "windwp/nvim-spectre", -- Spectre for find and replace
  "mhartington/formatter.nvim",
  "kyazdani42/nvim-web-devicons",
  "lukas-reineke/indent-blankline.nvim",

  -- Useful status updates for LSP
  { "j-hui/fidget.nvim", opts = { window = { border = "rounded", blend = 0 } } },

  { "numToStr/Comment.nvim", opts = {} },
  "rmagatti/auto-session",
  -- "airblade/vim-gitgutter",
  "mhinz/vim-signify",
  "weilbith/nvim-code-action-menu",
  -- "iamcco/markdown-preview.nvim",

  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup()
    end,
  },
}
