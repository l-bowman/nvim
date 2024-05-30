-- JavaScript and TypeScript -------------------------------
local mason_registry = require("mason-registry")

local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
  .. "/node_modules/@vue/language-server"

require("lspconfig").tsserver.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
      },
    },
  },
  -- tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})
