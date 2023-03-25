return {
  {
    "LeonHeidelbach/trailblazer.nvim",
    config = function()
      require("trailblazer").setup({
        {
          auto_save_trailblazer_state_on_exit = true,
          auto_load_trailblazer_state_on_enter = true,
        },
      })
    end,
  },
}
