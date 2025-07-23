return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })
      local registry = require("mason-registry")

      -- auto install formatters
      for _, pkg_name in ipairs({ "stylua", "prettier", "autopep8" }) do
        local ok, pkg = pcall(registry.get_package, pkg_name)
        if ok then
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "astro",
          "bashls",
          "cssls",
          "emmet_ls",
          "eslint",
          "graphql",
          "html",
          "jdtls",
          "jsonls",
          "lua_ls",
          "marksman",
          "prismals",
          "pyright",
          -- "rust_analyzer",
          "tailwindcss",
          "vtsls",
          "vue_ls",
          "yamlls",
        },
        automatic_installation = true,
      })
    end,
  },
}
