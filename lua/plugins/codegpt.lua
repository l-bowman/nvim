return {
  {
    "dpayne/CodeGPT.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("codegpt.config")
      vim.g["codegpt_commands"] = {
        ["code_edit"] = {
          model = "gpt-3.5-turbo",
          -- model = "gpt-4",
          max_tokens = 4096,
          temperature = 0.6,
          -- temperature = 0.9,
          number_of_choices = 1,
          system_message_template = "",
          user_message_template = "",
          callback_type = "replace_lines",
        },
        ["chat"] = {
          model = "gpt-3.5-turbo",
          -- model = "gpt-4",
          max_tokens = 4096,
          temperature = 0.6,
          -- temperature = 0.9,
          number_of_choices = 1,
          system_message_template = "",
          user_message_template = "",
          callback_type = "replace_lines",
        },
      }
    end,
  },
}
