return {
  {
    dir = "~/Documents/dev/nvim-plugins/timewarp.nvim",
    -- "l-bowman/timewarp.nvim",
    config = function()
      require("timewarp").setup({
        -- max_history = 100,
        -- edit_grouping_range = 5,
      })
    end,
  },
}
