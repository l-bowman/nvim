-- Vue JS --------------------------------------
-- require("lspconfig").volar.setup({})

-- Vue JS --------------------------------------
-- require("lspconfig").vuels.setup({})
require("lspconfig").volar.setup({
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },

  init_options = {
    typescript = {
      tsdk = os.getenv("HOME") .. "/.nvm/versions/node/v14.19.0/lib/node_modules/typescript/lib",
    },
  },
})