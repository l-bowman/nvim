-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  -- NOTE: plugins here require little to no configuratin
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  -- "tpope/vim-surround",
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
  "tpope/vim-unimpaired",
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "voldikss/vim-browser-search",
  "sindrets/diffview.nvim",
  "christoomey/vim-tmux-navigator",

  { "akinsho/git-conflict.nvim", version = "*", config = true },

  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup()
    end,
  },

  "windwp/nvim-ts-autotag", -- auto close and rename tags
  -- "simonward87/nvim-ts-autotag", -- Not sure why Will moved to this. Needs
  -- investigation
  "windwp/nvim-spectre",
  "mhartington/formatter.nvim",
  "kyazdani42/nvim-web-devicons",

  -- Useful status updates for LSP
  { "j-hui/fidget.nvim", opts = { window = { border = "rounded", blend = 0 } }, tag = "legacy" },

  { "numToStr/Comment.nvim", opts = {} },
  -- "airblade/vim-gitgutter",
  "mhinz/vim-signify",
  -- "weilbith/nvim-code-action-menu", -- This one is not working great.
  -- Better code action previews
  {
    "aznhe21/actions-preview.nvim",
  },
  -- "aznhe21/actions-preview.nvim" -- alternative?

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
