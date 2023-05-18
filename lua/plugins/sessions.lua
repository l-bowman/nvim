return {
  {
    "rmagatti/session-lens",
    dependencies = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" },
    config = function()
      require("auto-session").setup({
        opts = { auto_session_use_git_branch = true },
      })
    end,
  },
}
