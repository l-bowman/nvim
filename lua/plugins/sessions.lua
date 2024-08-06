return {
  {
    "rmagatti/session-lens",
    dependencies = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
    config = function()
      require("auto-session").setup({
        auto_session_use_git_branch = true,
        auto_save_enabled = true,
        silent_restore = false,
      })
    end,
  },
}
