require("lspconfig").rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
        enable = true,
        extraArgs = { "--target-dir", "./rust-analyzer-target" },
      },
      check = {
        command = "clippy",
      },
      diagnostics = {
        enable = true,
      },
    },
  },
})
