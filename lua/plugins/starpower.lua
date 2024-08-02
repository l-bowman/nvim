return {
  {
    dir = "~/Documents/dev/nvim-plugins/starpower.nvim",
    -- "l-bowman/starpower.nvim",
    config = function()
      require("starpower").setup({
        protected_groups = { "references", "backend", "frontend" },
        redraw_statusline = true,
        redraw_tabline = true,
      })
    end,
  },
}
