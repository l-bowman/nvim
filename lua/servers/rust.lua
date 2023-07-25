require("lspconfig").rust_analyzer.setup({
  rust_analyzer = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
        enable = true,
        extraArgs = { "--target-dir", "./rust-analyzer-target" },
      },
    },
  },
})
