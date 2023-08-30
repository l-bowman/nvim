return {
  -- NOTE: plugins here require little to no configuratin
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "voldikss/vim-browser-search",
  "ThePrimeagen/harpoon",
  "sindrets/diffview.nvim",
  "christoomey/vim-tmux-navigator",

  "windwp/nvim-ts-autotag", -- auto close and rename tags
  -- "simonward87/nvim-ts-autotag", -- Not sure why Will moved to this. Needs
  -- investigation
  "windwp/nvim-spectre",
  "mhartington/formatter.nvim",
  "kyazdani42/nvim-web-devicons",
  "lukas-reineke/indent-blankline.nvim",

  -- Useful status updates for LSP
  { "j-hui/fidget.nvim", opts = { window = { border = "rounded", blend = 0 } }, tag = "legacy" },

  { "numToStr/Comment.nvim", opts = {} },
  -- "airblade/vim-gitgutter",
  "mhinz/vim-signify",
  "weilbith/nvim-code-action-menu", -- This one is not working great.

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
