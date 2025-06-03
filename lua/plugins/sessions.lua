return {
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
      require("auto-session").setup({
        auto_save = true,
        continue_restore_on_error = false,
        git_use_branch_name = true,
      })
    end,
  },
  {
    "rmagatti/session-lens",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("session-lens").setup({})
    end,
  },
}
