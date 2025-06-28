return {
  {
    "neovim/nvim-lspconfig",
    event = "VimEnter",
    dependencies = { "folke/neodev.nvim", "saghen/blink.cmp" },
    config = function()
      -- Setup neovim lua configuration
      require("neodev").setup()

      -- rounded border
      require("lspconfig.ui.windows").default_options.border = "rounded"

      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          prefix = "●", -- Could be '●', '▎', 'x'
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- TS/JS
      local vue_language_server_path =
        vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")
      vim.lsp.config("ts_ls", {
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_language_server_path,
              languages = { "vue" },
            },
          },
        },
        tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "vue",
        },
        cmd = { "typescript-language-server", "--stdio" },
        capabilities = capabilities,
      })
      vim.lsp.enable("ts_ls")

      -- Vue JS
      vim.lsp.config("vue_ls", { capabilities = capabilities })
      vim.lsp.enable("vue_ls")

      -- CSS
      local css_settings = {
        validate = true,
        lint = {},
      }

      vim.lsp.config("cssls", {
        capabilities = capabilities,
        settings = {
          css = css_settings,
          less = {
            validate = true,
          },
          scss = {
            validate = true,
          },
        },
      })
      vim.lsp.enable("cssls")

      -- HTML
      vim.lsp.config("html", {
        capabilities = capabilities,
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "php" },
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
        },
      })
      vim.lsp.enable("html")

      -- Emmet
      vim.lsp.config("emmet_ls", {
        capabilities = capabilities,
      })
      vim.lsp.enable("emmet_ls")

      vim.lsp.config("eslint-lsp", {
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "package.json",
            ".eslintrc",
            ".eslintrc.json",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.js",
            ".eslintrc.cjs"
          )(fname) or vim.fn.getcwd()
        end,
      })
      vim.lsp.enable("eslint-lsp")

      -- Astro
      vim.lsp.config("astro", { capabilities = capabilities })
      vim.lsp.enable("astro")

      -- Markdown
      vim.lsp.enable("marksman")

      -- Prisma
      vim.lsp.enable("prismals")

      -- php
      -- vim.lsp.enable("intelephense")

      -- Bash
      vim.lsp.enable("bashls")

      -- Python
      vim.lsp.enable("pyright")

      -- Java
      vim.lsp.enable("jdtls")

      -- Yaml
      vim.lsp.enable("yamlls")

      -- Go
      -- vim.lsp.enable("gopls")

      -- GraphQL
      vim.lsp.enable("graphql")

      -- Rust
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              enable = true, -- Enable on-save checks
              command = "clippy", -- Use Clippy for linting
              allFeatures = true, -- Check all features
            },
            assist = {
              importGranularity = "module",
              importPrefix = "crate",
            },
            cargo = {
              allFeatures = true,
            },
            diagnostics = {
              enable = true, -- Enable diagnostics
              disabled = { "unresolved-proc-macro" }, -- Disable specific diagnostics if needed
            },
            procMacro = {
              enable = true, -- Enable procedural macros
            },
            rustfmt = {
              overrideCommand = { "rustfmt", "--edition=2021" }, -- Use the latest edition
            },
            -- Add more settings as needed
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      -- Lua
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = "LuaJIT",
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { "vim" },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = {
                vim.env.VIMRUNTIME .. "/lua", -- core Neovim API
                vim.env.VIMRUNTIME .. "/lua/vim/lsp", -- lspconfig / diagnostics
                vim.fn.stdpath("config") .. "/lua", -- my config
              },
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")
    end,
  },
}
