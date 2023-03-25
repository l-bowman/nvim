-- Prettier function for formatter
local prettier = function()
  return {
    exe = "prettier",
    args = {
      "--config-precedence",
      "prefer-file",
      -- you can add more global setup here
      "--stdin-filepath",
      vim.fn.shellescape(vim.api.nvim_buf_get_name(0)),
    },
    stdin = true,
    try_node_modules = true,
  }
end

-- Define global function to format the current buffer
_G.FormatWrite = function()
  local opts = {
    -- Get the formatter for the current filetype
    -- You can add more filetypes to this table if needed
    filetype = vim.tbl_filter(function(ft)
      return ft == vim.bo.filetype
    end, {
      "typescriptreact",
      "javascriptreact",
      "javascript",
      "typescript",
      "json",
      "jsonc",
      "html",
      "css",
      "scss",
      "graphql",
      "markdown",
      "vue",
      "astro",
      "yaml",
      "go",
      "lua",
      "python",
      "rust",
    }),
  }

  require("formatter").format(opts, prettier())
  vim.cmd("write")
end

return {
  {
    "mhartington/formatter.nvim",
    opts = {
      logging = false,
      filetype = {
        typescriptreact = { prettier },
        javascriptreact = { prettier },
        javascript = { prettier },
        typescript = { prettier },
        json = { prettier },
        jsonc = { prettier },
        html = { prettier },
        css = { prettier },
        scss = { prettier },
        graphql = { prettier },
        markdown = { prettier },
        vue = { prettier },
        astro = { prettier },
        yaml = { prettier },
        go = {
          -- goimport
          function()
            return {
              exe = "gofmt",
              args = { "-w" },
              stdin = false,
            }
          end,
        },
        lua = {
          -- Stylua
          function()
            return {
              exe = "stylua",
              args = {},
              stdin = false,
            }
          end,
        },
        python = {
          -- autopep8
          function()
            return {
              exe = "autopep8",
              args = { "--in-place" },
              stdin = false,
            }
          end,
        },
        rust = {
          function()
            return {
              exe = "rustfmt",
              stdin = true,
            }
          end,
        },
      },
    },
    config = function(_, opts)
      require("formatter").setup(opts)
      -- Runs Formmater on save
      -- vim.api.nvim_create_autocmd("BufWritePost", {
      --   pattern = {
      --     "*.js",
      --     "*.mjs",
      --     "*.cjs",
      --     "*.jsx",
      --     "*.ts",
      --     "*.tsx",
      --     "*.css",
      --     "*.scss",
      --     "*.md",
      --     "*.html",
      --     "*.lua",
      --     "*.json",
      --     "*.jsonc",
      --     "*.vue",
      --     "*.py",
      --     "*.gql",
      --     "*.graphql",
      --     "*.go",
      --     "*.rs",
      --     "*.astro",
      --   },
      --   command = "FormatWrite",
      -- })
    end,
  },
}
