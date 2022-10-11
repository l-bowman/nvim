local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  -- lsp
  use("neovim/nvim-lspconfig")

  -- Telescope
  use({
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })

  --Indent lines
  use("lukas-reineke/indent-blankline.nvim")

  -- LuaLine
  use({
    "hoob3rt/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })

  -- quickfix hacks
  -- use("sk1418/QFGrep")

  -- Autocomplete
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-cmdline", -- command line
      "hrsh7th/cmp-buffer", -- buffer completions
      "hrsh7th/cmp-nvim-lua", -- nvim config completions
      "hrsh7th/cmp-nvim-lsp", -- lsp completions
      "hrsh7th/cmp-path", -- file path completions
      "saadparwaiz1/cmp_luasnip", -- snippets completions
    },
  })

  -- snippets
  use({
    "L3MON4D3/LuaSnip",
    requires = {
      "rafamadriz/friendly-snippets",
    },
  })

  --octo
  use({
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "kyazdani42/nvim-web-devicons",
    },
  })

  -- tpope
  use("tpope/vim-fugitive")
  use("tpope/vim-surround")
  use("tpope/vim-abolish")

  -- commenting
  use("JoosepAlviste/nvim-ts-context-commentstring")
  use({ "numToStr/Comment.nvim", tag = "v0.6" })

  -- move between kitty windows
  use("knubie/vim-kitty-navigator")

  -- windwp
  use("windwp/nvim-ts-autotag") -- auto close and rename tags
  use("windwp/nvim-autopairs")

  -- Formatting
  use("mhartington/formatter.nvim")

  use("airblade/vim-gitgutter")

  -- hightlight matching tag in html,jsx etc.
  use("leafOfTree/vim-matchtag")

  -- Undotree
  use("mbbill/undotree")

  -- file tree
  use("kyazdani42/nvim-tree.lua")

  -- icons
  use("kyazdani42/nvim-web-devicons")

  -- icons in completion
  use("onsails/lspkind-nvim")

  -- Folke plugins
  -- Theme
  use("folke/tokyonight.nvim")

  -- Trouble
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup({})
    end,
  })

  -- WhichKey
  use("folke/which-key.nvim")

  -- Todo comments
  use({
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup({})
    end,
  })

  --Noice
  use({
    "folke/noice.nvim",
    event = "VimEnter",
    config = function()
      require("noice").setup()
      require("notify").setup({
        background_colour = "#1a1b26",
      })
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  })

  -- Colorizer
  use("norcalli/nvim-colorizer.lua")

  -- jsonc file type for json - comments in json
  use("kevinoid/vim-jsonc")

  -- bufferline for buffers in 'tabs'
  use({ "akinsho/bufferline.nvim", tag = "*", requires = "kyazdani42/nvim-web-devicons" })

  -- better code action menu
  use({
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
  })

  -- sessions
  use({
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Projects" },
      })
    end,
  })

  use({
    "rmagatti/session-lens",
    config = function()
      require("session-lens").setup({--[[your custom config--]]
      })
    end,
  })

  -- Dashboard
  use("goolord/alpha-nvim")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
