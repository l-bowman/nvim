require("lspconfig").rust_analyzer.setup({
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { allFeatures = true, command = "clippy" },
    },
  },
})
