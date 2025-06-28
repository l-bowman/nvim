-- Temperature: This parameter controls the randomness of the model's output. Higher values (close to 1.0) make the output more diverse but also more unpredictable, while lower values (close to 0.0) make the output more deterministic, but also more consistent. If you want very consistent code formatting or style, a lower temperature might be desirable. If you want more creative solutions or unique fixes to bugs, a higher temperature might be useful.

-- Top P (also known as nucleus sampling): This is a method of generating output where you only consider the top options that, cumulatively, make up a certain probability p. This can create a good balance between diversity and quality of output. A higher value will consider a larger set of options, making the output potentially more diverse, while a lower value will consider a smaller set, potentially improving consistency.

-- n: How many chat completion choices to generate for each input message.

return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        actions_paths = { "~/.config/nvim/chatgpt-actions.json" },
        openai_params = {
          model = "gpt-4o-mini",
          max_tokens = 4096,
        },
        openai_edit_params = {
          model = "gpt-4o-mini",
          max_tokens = 4096,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
