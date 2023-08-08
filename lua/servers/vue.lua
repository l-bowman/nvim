-- Vue JS --------------------------------------
-- require("lspconfig").volar.setup({})

-- Vue JS --------------------------------------
-- require("lspconfig").vuels.setup({})
require("lspconfig").volar.setup({
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },

  init_options = {
    typescript = {
      -- tsdk = os.getenv("HOME") .. "/.nvm/versions/node/v14.19.0/lib/node_modules/typescript/lib",
      tsdk = os.getenv("HOME") .. "/.nvm/versions/node/v16.19.0/lib/node_modules/typescript/lib",
      -- tsdk = "./node_modules/typescript/lib",
      -- tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
      -- tsdk = "/Users/lukebowman/Documents/dev/monorepo/node_modules/typescript/lib",
    },
  },
})
