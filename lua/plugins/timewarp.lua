return {
  {
    dir = "~/Documents/dev/nvim-plugins/timewarp.nvim",
    -- "l-bowman/timewarp.nvim",
    config = function()
      require("timewarp").setup({
        max_history = 3,
      })
    end,
  },
}
