return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "folke/neodev.nvim" },
    config = function()
      -- Setup neovim lua configuration
      require("neodev").setup()
      -- require all language server modules
      require("servers.astro")
      require("servers.bash")
      require("servers.css")
      require("servers.deno")
      require("servers.emmet")
      require("servers.eslint")
      require("servers.gql")
      require("servers.go")
      require("servers.html")
      require("servers.java")
      require("servers.json")
      require("servers.luals")
      require("servers.markdown")
      require("servers.prisma")
      require("servers.python")
      require("servers.rust")
      require("servers.tailwind")
      require("servers.typescript")
      require("servers.vue")
      require("servers.yaml")

      -- rounded border on :LspInfo
      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- Customization and appearance -----------------------------------------
      -- change gutter diagnostic symbols
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        virtual_text = {
          source = "if_many",
          prefix = "●", -- Could be '●', '▎', 'x'
        },
        float = {
          source = true,
        },
        severity_sort = true,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })
    end,
  },
}
