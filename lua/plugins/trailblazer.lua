vim.cmd("autocmd VimLeavePre * TrailBlazerSaveSession")
vim.cmd("autocmd SessionLoadPost * TrailBlazerLoadSession")

return {
  {
    "LeonHeidelbach/trailblazer.nvim",
    config = function()
      require("trailblazer").setup({
        {
          --These don't seem to work.
          auto_save_trailblazer_state_on_exit = true,
          auto_load_trailblazer_state_on_enter = true,
        },
      })
    end,
  },
}
