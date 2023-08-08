return {
  {
    "dpayne/CodeGPT.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("codegpt.config")
      vim.g["codegpt_commands_defaults"] = {
        ["completion"] = {
          model = "gpt-4",
          temperture = "0.9",
        },
      }
    end,
  },
}
