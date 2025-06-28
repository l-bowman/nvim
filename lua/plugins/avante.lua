return {
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      -- conditionally use the correct build system for the current OS
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    mode = "legacy",
    opts = {
      -- add any opts here
      -- for example
      -- provider = "openai",
      -- provider = "claude | ollama | openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "o4-mini",
          api_key = "OPENAI_API_KEY",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            -- temperature = 0.75,
            max_tokens = 8192,
          },
        },
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          -- model = "claude-3-7-sonnet-20250219",
          -- api_key = "ANTHROPIC_API_KEY",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 8192,
          },
        },
        -- provider = "ollama",
        -- providers = {
        --   ollama = {
        --     endpoint = "http://localhost:11434",
        --     model = "deepseek-r1:8b",
        --   },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
